//
//  Telemetry.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The only telemetry surface SDK code sees. Thread-safe, never throws, returns immediately.
package protocol Telemetry: Sendable {
    var isActive: Bool { get }
    func report(_ event: TelemetryEvent)
}
