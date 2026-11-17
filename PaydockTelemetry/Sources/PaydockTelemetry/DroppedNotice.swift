//
//  DroppedNotice.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The hour's dropped notice of one reason while it waits to be sent (spec § 5.8).
package struct DroppedNotice: Sendable, Equatable {
    package let id: String
    package let count: Int
    /// UTC epoch milliseconds.
    package let createdAt: Int64

    package init(id: String, count: Int, createdAt: Int64) {
        self.id = id
        self.count = count
        self.createdAt = createdAt
    }
}
