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

## Structure

- **Sources/PaydockTelemetry**: Library source code
- **Tests/PaydockTelemetryTests**: Unit tests

The standalone manifest lets the target build and test on its own: `cd PaydockTelemetry && swift test`.
