//
//  NoOpDurableStore.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Stores nothing: save, remove and prune do nothing, a crash save returns false, oldest gives nothing, count is 0.
package struct NoOpDurableStore: DurableStore {
    package init() {}
    package func save(_ record: TelemetryRecord) {}
    @discardableResult package func saveCrash(_ record: TelemetryRecord, timeout: TimeInterval) -> Bool { false }
    package func oldest(max: Int) -> [TelemetryRecord] { [] }
    package func remove(ids: [String]) {}
    package func prune(now: Int64) -> PruneResult { PruneResult() }
    package func count() -> Int { 0 }
}
