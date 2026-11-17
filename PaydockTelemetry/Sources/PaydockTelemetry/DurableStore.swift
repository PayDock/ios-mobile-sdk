//
//  DurableStore.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The disk is the queue: every record is kept until its batch is accepted or rejected (R_05, R_06).
package protocol DurableStore: Sendable {
    /// Upsert by record id; atomic.
    func save(_ record: TelemetryRecord)
    /// By `timeUnixMillis`, then the id's sequence as a number.
    func oldest(max: Int) -> [TelemetryRecord]
    func remove(ids: [String])
    /// `now`: UTC epoch milliseconds.
    func prune(now: Int64) -> PruneResult
    func count() -> Int
}
