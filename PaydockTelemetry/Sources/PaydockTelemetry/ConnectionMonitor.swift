//
//  ConnectionMonitor.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The connection type every record carries at its creation (R_17).
package protocol ConnectionMonitor: Sendable {
    /// Registers. Called only by the active runtime's start.
    func start()
    /// `.unknown` until the first update.
    func current() -> NetworkConnectionType
}
