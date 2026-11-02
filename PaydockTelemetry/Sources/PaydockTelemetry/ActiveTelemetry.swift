//
//  ActiveTelemetry.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
/// Bound when activation passes. A placeholder until the MVI core (MD-34): it reports active and does nothing
/// else — no thread, queue, file, session or registration.
package final class ActiveTelemetry: Telemetry, TelemetryRuntime {
    package let credentials: TelemetryCredentials
    package let level: TelemetryLevel

    package init(credentials: TelemetryCredentials, level: TelemetryLevel) {
        self.credentials = credentials
        self.level = level
    }

    package var isActive: Bool { true }
    package func report(_ event: TelemetryEvent) {}
    package func start() {}
}
#endif
