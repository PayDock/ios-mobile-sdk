# PaydockTelemetry

The internal telemetry target of MobileSDK in the Paydock iOS SDK.

## Overview

`PaydockTelemetry` defines the telemetry facade, its no-op implementation and the typed events SDK code reports.
It is internal to MobileSDK: a dependency of the `MobileSDK` target, never a product, and every declaration uses
`package` access, so nothing in it is visible to merchants.

The target is dormant until activation: today the SDK binds nothing and reports nothing, and `NoOpTelemetry` does
nothing. Activation arrives in a later change.

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

Nothing calls the pipeline yet: no send, no registration, no new thread or storage until I7 wires the exporter.

`GoldenFixturesTests` checks every shared and iOS golden fixture in `Tests/PaydockTelemetryTests/Fixtures` against its
expected JSON. The fixtures are copied from the planning repo and never edited here: a mismatch is fixed in the
builder or the encoder. `AllowlistTests` fails the build when an unlisted key, a wrong kind or a sensitive value could
be encoded.

## Structure

- **Sources/PaydockTelemetry**: Library source code
- **Tests/PaydockTelemetryTests**: Unit tests
- **Tests/PaydockTelemetryTests/Fixtures**: The golden fixtures (copied, never edited)

The standalone manifest lets the target build and test on its own: `cd PaydockTelemetry && swift test`.
