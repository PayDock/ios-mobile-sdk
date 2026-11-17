//
//  NoOpDurableStore.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Stores nothing: save, remove and prune do nothing, oldest gives nothing, count is 0.
package struct NoOpDurableStore: DurableStore {
    package init() {}
    package func save(_ record: TelemetryRecord) {}
    package func oldest(max: Int) -> [TelemetryRecord] { [] }
    package func remove(ids: [String]) {}
    package func prune(now: Int64) -> PruneResult { PruneResult() }
    package func count() -> Int { 0 }
}
