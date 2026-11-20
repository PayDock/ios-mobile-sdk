# PaydockTelemetry

The internal telemetry target of MobileSDK in the Paydock iOS SDK.

## Overview

`PaydockTelemetry` defines the telemetry facade, its no-op implementation and the typed events SDK code reports.
It is internal to MobileSDK: a dependency of the `MobileSDK` target, never a product, and every declaration uses
`package` access, so nothing in it is visible to merchants.

The SDK binds telemetry at start (`Sources/MobileSDK/Telemetry/TelemetryBinding.swift`), in every build, debug and
release, by one path: the collector table is the only input. Sandbox and staging send to the dev collector
(`TelemetryCollector.devLogsURL`) and production to the prod collector (`TelemetryCollector.prodLogsURL`); an
environment without a collector binds `NoOpTelemetry`, which creates no file, directory, client, observer, monitor or
session. `TelemetryActivation` needs a non-blank endpoint. No build sends a key or reads a local setting. A test process
(the Xcode test runner, or any process with `XCTestConfigurationFilePath`: hosted unit tests) always binds the no-op
(`TelemetryTestHost`).

The stand-in hosts are compiled only in debug builds, so a release binary holds none of them. `app.debuggable` is true
in a debug build, false in a release one. The privacy manifest, `Resources/PrivacyInfo.xcprivacy`, is a resource of
this target (`PrivacyManifestTests`).

## Usage

From MobileSDK, import the module and refer only to the `Telemetry` facade, `TelemetryEvent` and `ReportSite`:

```swift
import PaydockTelemetry
```

SDK code outside `Sources/MobileSDK/Telemetry/` reports only through `SdkTelemetry` and runs its `Task`s only through
`SdkTask` (see SDK errors, uncaught errors and widget usage). `PackageOnlyTests` keeps every declaration at `package`
access, and `TelemetrySeamTests` in `MobileSDKTests` keeps the rest of the SDK behind the facade and the events.

## Records

A reported event becomes an OTLP log record through pure functions over value types (spec § 5):

1. `RecordFactory.create` builds a `TelemetryRecord` from a `PendingRecord`: the attributes in `Allowlist.recordKeys`
   order, the stack trace from `StackTraceFormatter` (frames through `StackFrame.sanitise`) and the body from
   `RecordBody`.
2. `Allowlist.filter` keeps only listed keys with the right kind and no sensitive-looking value, and rebuilds the body;
   `Allowlist.violations` says why a batch must not be sent.
3. `SendStamp.stamp` applies the late-record rule at send time (`paydock.occurred_at`, formatted by `UtcTimestamp`).
4. `OtlpLogEncoder.encode` writes one deterministic OTLP/HTTP JSON export request for the batch and its
   `ResourceAttributes`.

Steps 1 and 2 run when a record is created; steps 3 and 4 run when it is sent (see Store and Exporter).

## Store

The disk is the queue. When active, every record is saved as one file the moment it is created: `FileDurableStore`
writes `<id>.json` (the record's `OtlpLogEncoder.recordJSON`) under `Application Support/paydock_telemetry/`, created on
the first save and excluded from backup. A file is deleted only when its batch is accepted or rejected, so a record
survives process death and is sent on a later launch. The store keeps at most 100 records or 1 MB and drops records
older than 156 h; `DuplicateGate` merges duplicates before an export and before a full store is pruned. At most 400
records are created per hour, and every drop is reported by one `paydock.telemetry.dropped` notice per reason and
hour. `FileManager` is used only in `FileDurableStore` and `FileStateStore`, and never for a date, size or capacity
attribute (`RequiredReasonApiTests`).

## Exporter

`ExportRunner` is the only sender. A flush runs every 10 s while records are pending, at once when 20 are pending,
right after start (so records from earlier runs go first) and when the app goes to the background (inside a short
background task). It sends batches of at most 50 records and 256 KB of JSON, oldest first, each stamped at send with
the gateway's clock offset and checked by the allowlist. `OtlpExporter` gzips each batch and `OtlpHttpTransport` posts
it with exactly the content-encoding and content-type headers on its own NetworkingLib client (15 s, kept out of the
debug log, never pinned). A success, a partial success included, removes the batch and counts any records the
collector refused; a 400 or any other non-retried status removes the batch as rejected, with no retry; 408, 429 and
5xx retry with back-off, honouring `Retry-After`; 413 splits the batch; 401 or 403 stops sending for the process. All of it runs on the
`com.paydock.telemetry` queue, never the main thread.

## SDK errors, uncaught errors and widget usage

When active, the SDK reports its own failures, the errors thrown in its `Task`s and the widgets a session opens. The
merchant's results are unchanged: every call returns at once while telemetry is inactive, never throws, and a failure
inside telemetry loses the record, never the merchant's result.

- **The calls** live in the main target, `Sources/MobileSDK/Telemetry/`: `SdkTelemetry.reportSdkError(_:widget:)`,
  `reportUncaught(_:widget:)` and `reportWidgetOpened(_:)`, with the widget names of `SdkWidget` (a widget both
  platforms have uses Android's name). A failure path calls `reportSdkError` once, right before it delivers the same
  value to the merchant unchanged; a failure the SDK swallows is reported with a `SilentFailure` code and still not
  delivered. Every `Task` runs through `SdkTask.run(widget:_:)` on the main actor; an error its body throws is reported
  as uncaught (`paydock.error.kind` `uncaught`), a `CancellationError` never.
- **The facts** come from `SdkErrorFacts` and each error type's exhaustive `TelemetryErrorFacts` switch: the type
  (a request error's case, an `NSError`'s domain and code, else the Swift type), the code (`WidgetError.code` or the
  `SilentFailure` code) and a cause chain of at most 8 such types. Never a message: no `customMessage`,
  `debugDescription`, localized description, wallet-token reason, PayPal SDK description or error body text.
- **The request rule**: an error a failed API request caused (a `RequestError`, or a widget error holding one or an
  error body) sends no SDK error, so a network failure is not counted twice. User cancellations and providers'
  outcomes (declined, referred) send none either.
- **The report site**: `reportSdkError` and `reportUncaught` capture `ReportSite.capture()` on the calling thread
  (`Thread.callStackReturnAddresses`, at most 64, and the thread's name) and nothing else. `ActiveTelemetry` hands it
  to `ReportSiteResolver` on the telemetry queue, which describes each address as an image offset (system symbols only)
  through the crash path's resolver and sets `paydock.exception.in_sdk` from the same frame classifier (absent without
  one). `RecordFactory` writes `in_sdk` from the event, absent when nil.
- **Widget usage**: each public widget reports itself once when it appears (an `.onAppear` on its outermost view, or
  the first statement of `makeUIView`); `ApplePayWidget` embeds `ApplePaySetupWidget` without a report of its own. The
  reducer remembers the widgets stored this session (`TelemetryState.openedWidgets`) and drops a repeat as
  `alreadyOpened`, before the hourly cap. A new SDK session records it again.

`ErrorPathScanTests` and `WidgetUsageScanTests` in `MobileSDKTests` scan the sources: the report calls per file, each
before its delivery, no `Task` outside `SdkTask`, no message text in the telemetry files, and one usage report per
widget.

## Payment attempts

When active, the SDK records each payment attempt in its payment widgets as two `INFO` records (D24, spec § 5.9),
so conversion and duration can be read per widget. They carry no amount, token, card data or message text, and no
real ID but the 3DS charge ID of the two 3DS widgets (D25).

- **`paydock.payment.started`** (`TelemetryEvent.paymentStarted`): `paydock.widget` and `paydock.payment.id`, a random
  lowercase UUID new per attempt. Body `paydock.payment.started · <widget>`.
- **`paydock.payment.finished`** (`TelemetryEvent.paymentFinished`): `paydock.widget`, `paydock.payment.id`,
  `paydock.payment.outcome` (`PaymentOutcome`: `success`, `declined`, `error` or `cancelled`),
  `paydock.payment.duration_ms` and, for the `error` outcome only, `paydock.error.code`, the code the merchant
  receives. Body `paydock.payment.finished · <widget> · <outcome>[ · <paydock.error.code>]`.

Two 3DS attributes (D25, § 5.9), last in the record, each absent when unknown:

- **`paydock.3ds.charge_id`** (string, on both records of `Standalone3DSWidget` and `MPGS3DSWidget` only): the 3DS
  charge ID Paydock issued, read from the widget's token at the start or, when the token has none, from the first
  message of the flow that carries one. Once set it never changes for the attempt; an empty value counts as none. The
  token itself is never sent. `Allowlist` checks it with the generic sensitive-value check.
- **`paydock.3ds.flow`** (string, on `paydock.payment.finished` of `Standalone3DSWidget` only, for the `success` and
  `declined` outcomes): how the shopper was authenticated, `TelemetryEvent.ThreeDSFlow` (`frictionless`, `challenge`
  or `decoupled`), the same value as the delivered `Standalone3DSResult.authenticationFlow`. Never on an `error` or
  `cancelled` finish, and never on `MPGS3DSWidget`. `Allowlist` accepts only the three values.

The body is unchanged: the 3DS attributes never enter it. The SDK seam (`SdkTelemetry.startPayment(_:charge3dsId:)`,
whose charge ID is read only when telemetry is active and only for the two 3DS widgets,
`SdkTelemetry.notePaymentCharge3dsId(_:on:)` and `SdkTelemetry.finishPayment(_:_:flow:)`) sends neither key for any
other widget.

The reducer's rules:

- It keeps the open attempts (`TelemetryState.openPayments`): those whose started record was stored and that have not
  finished, oldest first, at most `TelemetryLimits.maxOpenPayments` (20). A 21st forgets the oldest.
- A start goes through the hourly cap like any record; a capped start opens nothing.
- A finish without an open attempt of its ID (never started, capped, forgotten, already finished, or started before
  the app relaunched) is dropped as `paymentNotOpen`, so every finished record has its started record.
- A finish of an open attempt is never capped: its record is created and counted even at the cap, so a started
  attempt is not counted as abandoned by the cap alone.
- `paydock.payment.duration_ms` is measured by the reducer on the monotonic clock (`elapsed` at the finish minus at the
  start, at least 0); any duration a caller passes is replaced.

`Allowlist` accepts the three payment keys and the two 3DS keys, a payment ID only in the UUID shape (the card-number
check would reject a random UUID with a long all-digit run), an outcome only among the four values and a flow only
among the three. `DuplicateGate` never merges payment
records: each attempt is its own.

## Network failures

When active, the SDK records every failed attempt of a Paydock API request as one `paydock.network.failure` record
(spec § 5.4). Requests are unchanged: the observer only reads, the stand-in hosts are compiled only in debug builds,
and `NoOpTelemetry` registers nothing.

- **The observer**: `start` registers one `NetworkFailureObserver` in `NetworkingLib.shared.requestObserver`
  (through `NetworkingLibObserverSlot`), on the calling thread, once per process. NetworkingLib calls it once per
  attempt, on the task that ran it. It forwards the observation to the observer it replaced first, then maps it with
  the pure `NetworkFailureFacts.event` and hands any event to the facade's `report`: it never blocks, never runs the
  reducer on the caller's thread and never changes the request. A retried connection failure gives one record per
  attempt (`attempt` 1, 2, …), so a timeout on the two retried calls (the wallet callback and the wallet config) gives
  two. A cancellation, a 2xx and an observation without a known method give none.
- **The failure** (`error.type`): a non-2xx status is `http_4xx` or `http_5xx` with the status, its group key and
  the API's structured codes from the error body (`ApiErrorBody`: `status`, `error.code`, `error_summary.code` and the
  gateway-specific codes); a 2xx that fails to decode is `decode` with its status; a URL error is a transport failure
  whose kind (`timeout`, `connection`, `tls`, `unknown`) comes from its code (`NetworkFailureFacts.transportKind`). A
  decode or transport failure's `exception.type` is its `RequestError` case or its `NSError` domain and code, with
  causes and no frames.
- **The templates**: `RouteTemplates` maps the real path to one of the eight § 5.4 templates, string for string with
  Android (`/v1/payment_sources/tokens`, `/v1/payment_sources/external_checkout`, `/v1/payment_sources/setup-tokens`,
  `/v1/payment_sources/setup-tokens/{id}/tokens`, `/v1/charges/wallet/capture`, `/v1/charges/wallet/{id}/decline`,
  `/v1/charges/wallet/callback`, `/v1/gateways/{id}/wallet-config`), after dropping the query and fragment; an empty
  ID segment still becomes `{id}`. A path outside the eight keeps only template literals and version segments, every
  other segment becomes `{id}`. `EndpointTemplateTests` in `MobileSDKTests` builds every SDK endpoint case and checks
  each maps to its template.
- **The hosts**: only the three API hosts (`NetworkFailureFacts.apiHosts`: `api.paydock.com`,
  `api-sandbox.paydock.com`, `apista.paydock.com`, the hosts `Constants.baseURL` gives each `SDKEnvironment`,
  `ApiHostsTests`) are reported, in every build. A debug build also accepts the two `DebugStandInHosts` the example
  app's timeout and offline triggers point the SDK at for one call; a release binary holds neither address. Telemetry's
  own endpoint host is excluded, so the exporter's requests never loop back as records; other traffic (BIN data, web
  views, the PayPal and Afterpay SDKs) never passes through NetworkingLib.
- **What is never sent**: the real path (its IDs), the query, the request or response body, a header, the error body's
  messages and descriptions, an error message or user info value, and a decode failure's field path. The record
  carries the method, the template, the host, the status or transport kind, the attempt and the API codes only; the
  allowlist checks the template and the group key shapes. Tests plant card-like, email-like and token-like values in
  each and check that none reaches a record.

A failed request also sends no SDK error (the request rule above), so it is recorded once (`NetworkFailureOnceTests`).

## Crashes

When active, the SDK records every crash in the app and marks the SDK's own with `paydock.exception.in_sdk`. The app's
crash handling is unchanged: the SDK's handler is chained, always calls the one it replaced, and waits at most 0.5 s.

- **Uncaught Objective-C exceptions**: `start` installs one link in the uncaught-exception handler chain
  (`ExceptionHandlerChain`), on the calling thread, once per process. `CrashRecorder` stores the record straight to the
  store on the crashing thread (waiting at most 0.5 s for its lock) and the handler always calls the handler it
  replaced. When a frame lies in the SDK's image, it also saves a crash marker.
- **MetricKit**: on a later launch, `MetricKitDiagnosticSource` delivers the crash and hang diagnostics, which
  `MetricKitPayload` parses (reading only the frames, the Mach exception type and the signal, never the termination
  reason, the memory region info or the exception reason) and `DiagnosticReader` turns into events through the
  reducer. The SIGABRT report of a crash the handler already recorded matches the marker and is skipped, so one crash
  gives one record.
- **The classifier** (spec § 7.2) never reads symbols: `start` reads the SDK's image through dyld
  (`DyldSdkImageReader`), turns its type metadata accessors into the code ranges of the SDK's modules (`FramePoints`)
  and keeps those of the last three builds, so a MetricKit report from an earlier build is still classified. A frame of
  an unknown build of the SDK's image leaves `in_sdk` absent.
- **State files**: `Application Support/paydock_telemetry/state/frame-points.json` (the ranges of at most three builds)
  and `crash-marker.json` (at most one marker), written by `FileStateStore`. The record store ignores `state/`.

`MetricKitPayload` reads `offsetIntoBinaryTextSegment` as the frame's offset in its image (spec § 7.2); this awaits a
check on the first real device crash, as the simulator delivers no MetricKit payloads. If it holds the image's load
address instead, the offset is `address` minus it, changed in `MetricKitPayload` only.

## Golden fixtures

`GoldenFixturesTests` checks every shared and iOS golden fixture in `Tests/PaydockTelemetryTests/Fixtures` against its
expected JSON. The fixtures are copied from the planning repo and never edited here: a mismatch is fixed in the
builder or the encoder. `AllowlistTests` fails the build when an unlisted key, a wrong kind or a sensitive value could
be encoded.

## Structure

- **Sources/PaydockTelemetry**: Library source code
- **Tests/PaydockTelemetryTests**: Unit tests
- **Tests/PaydockTelemetryTests/Fixtures**: The golden fixtures (copied, never edited); `metrickit/` holds synthetic
  MetricKit payloads of this repo's own

The standalone manifest lets the target build and test on its own: `cd PaydockTelemetry && swift test`, and in the
release configuration `cd PaydockTelemetry && swift test -c release`.
