//
//  NoOpTelemetry.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Bound when telemetry is disabled. Does nothing: no thread, queue, file, directory, client, observer, monitor,
/// session or registration (RS-2, R_15).
package struct NoOpTelemetry: Telemetry, TelemetryRuntime {
    package init() {}
    package var isActive: Bool { false }
    package func report(_ event: TelemetryEvent) {}
    package func start() {}
    package func sendTestRecord() {}
}
