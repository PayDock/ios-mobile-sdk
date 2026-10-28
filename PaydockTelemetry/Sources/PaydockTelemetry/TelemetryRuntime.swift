//
//  TelemetryRuntime.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Lifecycle, held only by the activation binding (MD-33); SDK code never sees it.
package protocol TelemetryRuntime: Sendable {
    func start()
}
