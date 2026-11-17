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
    /// Records on disk not yet exported, as last counted.
    package var pending: Int = 0
    /// UTC epoch milliseconds.
    package var lastExport: Int64?
    /// A 10 s timer is armed; only its own tick clears it.
    package var flushScheduled: Bool = false
    /// 401/403 or give-up: no export or timer for the rest of the process.
    package var exportStopped: Bool = false
    /// Monotonic milliseconds; the start of the current hour of the cap and the notices.
    package var windowStart: Int64?
    /// Records created this hour, notices excluded.
    package var createdInWindow: Int = 0
    package var notices: [TelemetryEvent.DroppedReason: DroppedNotice] = [:]
    /// Widgets whose opened record was stored this session (D19, R_09).
    package var openedWidgets: Set<String> = []

    package init(level: TelemetryLevel, enabled: Bool, sessionId: String) {
        self.level = level
        self.enabled = enabled
        self.sessionId = sessionId
    }
}
