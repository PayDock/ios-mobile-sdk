//
//  TelemetryRuntime.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Lifecycle, held only by the activation binding (MD-33); SDK code never sees it.
package protocol TelemetryRuntime: Sendable {
    func start()
    /// The debug-only test record (R_16): stored and sent right after start. `NoOpTelemetry` does nothing.
    func sendTestRecord()
    /// R_13: the active runtime raises a test Objective-C exception from SDK code on the main thread after
    /// testCrashDelayMilliseconds. `NoOpTelemetry` does nothing.
    func raiseTestCrash()
}
