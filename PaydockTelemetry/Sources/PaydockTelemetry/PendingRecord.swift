//
//  PendingRecord.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// A reported event on its way to becoming a record (RecordFactory). Typed fields only.
package struct PendingRecord: Sendable, Equatable {
    /// `"<sessionId>-<sequence>"` (`log.record.uid`).
    package let id: String
    package let sessionId: String
    package let event: TelemetryEvent
    /// UTC epoch milliseconds, when the reducer created it.
    package let createdAt: Int64

    package init(id: String, sessionId: String, event: TelemetryEvent, createdAt: Int64) {
        self.id = id
        self.sessionId = sessionId
        self.event = event
        self.createdAt = createdAt
    }
}
