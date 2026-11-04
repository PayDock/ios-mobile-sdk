//
//  DurableStore.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Records kept across launches until exported.
package protocol DurableStore: Sendable {
    func save(_ record: PendingRecord)
    func loadAll() -> [PendingRecord]
    func remove(ids: [String])
    func prune(now: Int64)
}
