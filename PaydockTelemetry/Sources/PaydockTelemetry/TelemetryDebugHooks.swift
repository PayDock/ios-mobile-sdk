//
//  TelemetryDebugHooks.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
/// The debug-only test record (R_16 of the export change) and test crash (R_13 of the crash change).
package protocol TelemetryDebugHooks: Sendable {
    /// Stored and sent right after start. `NoOpTelemetry` does nothing.
    func sendTestRecord()
    /// The active runtime raises a test Objective-C exception from SDK code on the main thread after
    /// testCrashDelayMilliseconds. `NoOpTelemetry` does nothing.
    func raiseTestCrash()
}
#endif
