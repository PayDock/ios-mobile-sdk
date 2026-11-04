//
//  TelemetryState.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// What the reducer remembers between intents.
package struct TelemetryState: Sendable, Equatable {
    package var level: TelemetryLevel
    package var enabled: Bool
    package var sessionId: String
    package var queued: Int = 0
    package var persisted: Int = 0
    /// UTC epoch milliseconds.
    package var lastExport: Int64?
    package var flushScheduled: Bool = false
    package var nextSequence: Int64 = 0
    /// Fingerprint → the record held in its collapse window.
    package var collapsing: [String: PendingRecord] = [:]

    package init(level: TelemetryLevel, enabled: Bool, sessionId: String) {
        self.level = level
        self.enabled = enabled
        self.sessionId = sessionId
    }
}
