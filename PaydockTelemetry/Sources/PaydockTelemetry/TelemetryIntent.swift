//
//  TelemetryIntent.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The reducer's single input. Only the target creates signals; the facade accepts events, never intents.
package enum TelemetryIntent: Sendable, Equatable {
    case reported(TelemetryEvent)
    case flush
    case appBackgrounded
    case levelChanged(TelemetryLevel)
}
