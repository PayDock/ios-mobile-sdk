//
//  NoOpDurableStore.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Stores nothing: save, remove and prune do nothing, loadAll gives nothing.
package struct NoOpDurableStore: DurableStore {
    package init() {}
    package func save(_ record: PendingRecord) {}
    package func loadAll() -> [PendingRecord] { [] }
    package func remove(ids: [String]) {}
    package func prune(now: Int64) {}
}
