//
//  RecordingDurableStore.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// An in-memory store, upserting by record id, that records every save.
final class RecordingDurableStore: DurableStore, @unchecked Sendable {
    private let lock = NSLock()
    private var byId: [String: PendingRecord] = [:]
    private var saveLog: [PendingRecord] = []

    var saved: [PendingRecord] { locked { saveLog } }

    func save(_ record: PendingRecord) {
        locked {
            byId[record.id] = record
            saveLog.append(record)
        }
    }

    func loadAll() -> [PendingRecord] {
        locked { byId.values.sorted { $0.id < $1.id } }
    }

    func remove(ids: [String]) {
        locked { ids.forEach { byId[$0] = nil } }
    }

    func prune(now: Int64) {}

    private func locked<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
