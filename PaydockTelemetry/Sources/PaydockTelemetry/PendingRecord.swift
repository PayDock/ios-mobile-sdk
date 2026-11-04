//
//  PendingRecord.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// A reported event on its way to becoming a record (RecordFactory, I5). Typed fields only.
package struct PendingRecord: Sendable, Equatable {
    /// `"<sessionId>-<sequence>"`, deterministic.
    package let id: String
    package let sessionId: String
    package let event: TelemetryEvent
    /// UTC epoch milliseconds.
    package let firstSeenAt: Int64
    /// `paydock.occurrences`.
    package var occurrences: Int

    package init(id: String, sessionId: String, event: TelemetryEvent, firstSeenAt: Int64, occurrences: Int = 1) {
        self.id = id
        self.sessionId = sessionId
        self.event = event
        self.firstSeenAt = firstSeenAt
        self.occurrences = occurrences
    }
}
