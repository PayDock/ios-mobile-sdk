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

From MobileSDK, import the module and refer only to the `Telemetry` facade and `TelemetryEvent`:

```swift
import PaydockTelemetry
```

`PackageOnlyTests` keeps every declaration at `package` access, and `TelemetrySeamTests` in `MobileSDKTests` keeps
the rest of the SDK behind the facade and the events.

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
hour. `FileManager` is used only in `FileDurableStore`, and never for a date, size or capacity attribute
(`RequiredReasonApiTests`).

## Exporter

`ExportRunner` is the only sender. A flush runs every 10 s while records are pending, at once when 20 are pending,
right after start (so records from earlier runs go first) and when the app goes to the background (inside a short
background task). It sends batches of at most 50 records and 256 KB of JSON, oldest first, each stamped at send with
the gateway's clock offset and checked by the allowlist. `OtlpExporter` gzips each batch and `OtlpHttpTransport` posts
it with the content-encoding, content-type and basic authorization headers on its own NetworkingLib client (15 s, kept
out of the debug log, never pinned). Failures retry with back-off; 401 or 403 stops sending for the process. All of it
runs on the `com.paydock.telemetry` queue, never the main thread, and every type that touches the file system, the
network or the app lifecycle is compiled only in debug builds.

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
- **Tests/PaydockTelemetryTests/Fixtures**: The golden fixtures (copied, never edited)

The standalone manifest lets the target build and test on its own: `cd PaydockTelemetry && swift test`.
