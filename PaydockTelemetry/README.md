# PaydockTelemetry

The internal telemetry target of MobileSDK in the Paydock iOS SDK.

## Overview

`PaydockTelemetry` defines the telemetry facade, its no-op implementation and the typed events SDK code reports.
It is internal to MobileSDK: a dependency of the `MobileSDK` target, never a product, and every declaration uses
`package` access, so nothing in it is visible to merchants.

The SDK binds telemetry at start (`Sources/MobileSDK/Telemetry/TelemetryBinding.swift`). Only a debug build of a
`com.paydock.` host app on the sandbox environment, with the local scheme's credentials, binds `ActiveTelemetry`;
everything else, and every release build, binds `NoOpTelemetry`, which creates no file, directory, client, observer,
monitor or session.

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
it with the content-encoding, content-type and basic authorization headers on its own NetworkingLib client (15 s, kept
out of the debug log, never pinned). Failures retry with back-off; 401 or 403 stops sending for the process. All of it
runs on the `com.paydock.telemetry` queue, never the main thread, and every type that touches the file system, the
network or the app lifecycle is compiled only in debug builds.

## SDK errors, uncaught errors and widget usage

When active, the SDK reports its own failures, the errors thrown in its `Task`s and the widgets a session opens. A
release build and a merchant app are unchanged: every call returns at once while telemetry is inactive, never throws,
and a failure inside telemetry loses the record, never the merchant's result.

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
  `alreadyOpened`, after the level and before the hourly cap; level `errors` drops widget usage. A new SDK session
  records it again.

`ErrorPathScanTests` and `WidgetUsageScanTests` in `MobileSDKTests` scan the sources: the report calls per file, each
before its delivery, no `Task` outside `SdkTask`, no message text in the telemetry files, and one usage report per
widget.

## Network failures

When active, the SDK records every failed attempt of a Paydock API request as one `paydock.network.failure` record
(spec § 5.4). A release build and a merchant app are unchanged: the observer, its library slot and the stand-in hosts
are compiled only in debug builds, and `NoOpTelemetry` registers nothing.

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

When active, the SDK records every crash in the app and marks the SDK's own with `paydock.exception.in_sdk`. A release
build and a merchant app are unchanged: none of the types below is compiled into a release build.

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

### Test crashes

In the same unshared scheme as the telemetry credentials (Run → Arguments → Environment Variables), debug builds only:

- `PAYDOCK_TELEMETRY_TEST_CRASH` = `true`: an active runtime raises a test Objective-C exception
  (`PaydockTelemetryTestCrash`) from SDK code on the main thread 3 s after start, recorded with `in_sdk` true. It does
  nothing while telemetry is inactive.
- `EXAMPLE_APP_TEST_CRASH` = `true`: the example app raises `ExampleAppTestCrash` from app code on the main thread 3 s
  after launch, recorded with `in_sdk` false.

Both end the process. Never put them in a shared scheme.

`scripts/check-crash-in-sdk.sh [<simulator udid>]` proves the classifier on a stripped build: it builds the example
app like a release (`SWIFT_OPTIMIZATION_LEVEL=-O SWIFT_COMPILATION_MODE=wholemodule ENABLE_TESTABILITY=NO
LD_EXPORT_GLOBAL_SYMBOLS=NO ENABLE_DEBUG_DYLIB=NO`: a debug configuration enables testability and exports global
symbols, which `strip` must keep), strips every symbol from the executable itself (`xcrun strip`: the target sets
`STRIP_INSTALLED_PRODUCT = NO` for its debug configurations, so build settings strip nothing) and re-signs the app ad
hoc (`codesign --force --sign -`), fails while any `MobileSDK` symbol is left, then runs both test crashes on the
simulator (telemetry active against a gateway that never answers) and expects one `nsexception` crash record each, with
`in_sdk` true for the SDK's and false for the app's. It prints one PASS or FAIL line per case and never collects
diagnostics.

## Test record

Set `PAYDOCK_TELEMETRY_SEND_TEST_RECORD` to `true` in the same unshared scheme as the telemetry credentials (Run →
Arguments → Environment Variables) to make an active runtime store and send one test record right after start: an SDK
error with `paydock.error.code` `TelemetryTestRecord` (`exception.type` `PaydockTelemetry.TelemetryTestRecord`). It
shows in devdock with the other records of the session. A release build has no such path, and the variable does
nothing while telemetry is inactive. Never put it in a shared scheme.

`GoldenFixturesTests` checks every shared and iOS golden fixture in `Tests/PaydockTelemetryTests/Fixtures` against its
expected JSON. The fixtures are copied from the planning repo and never edited here: a mismatch is fixed in the
builder or the encoder. `AllowlistTests` fails the build when an unlisted key, a wrong kind or a sensitive value could
be encoded.

## Structure

- **Sources/PaydockTelemetry**: Library source code
- **Tests/PaydockTelemetryTests**: Unit tests
- **Tests/PaydockTelemetryTests/Fixtures**: The golden fixtures (copied, never edited); `metrickit/` holds synthetic
  MetricKit payloads of this repo's own

The standalone manifest lets the target build and test on its own: `cd PaydockTelemetry && swift test`.
