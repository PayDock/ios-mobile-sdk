//
//  TelemetryLevel.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// How much telemetry records: nothing, errors only, or everything. Applied by the activation slice (MD-33).
package enum TelemetryLevel: Sendable, Equatable {
    case off, errors, all
}
