//
//  RecordingDurableStore.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// An in-memory store, upserting by record id, that records every save and prune, answers prune with a set result and
/// records the thread and queue label of every call.
final class RecordingDurableStore: DurableStore, @unchecked Sendable {
    struct Call {
        let isMainThread: Bool
        let queueLabel: String
    }

    private let lock = NSLock()
    private var callLog: [Call] = []
    private var byId: [String: TelemetryRecord] = [:]
    private var saveLog: [TelemetryRecord] = []
    private var pruneLog: [Int64] = []
    private var scriptedPrune = PruneResult()

    var saved: [TelemetryRecord] { locked { saveLog } }
    var pruneTimes: [Int64] { locked { pruneLog } }
    var calls: [Call] { locked { callLog } }

    var pruneResult: PruneResult {
        get { locked { scriptedPrune } }
        set { locked { scriptedPrune = newValue } }
    }

    func save(_ record: TelemetryRecord) {
        noteCall()
        locked {
            byId[record.id] = record
            saveLog.append(record)
        }
    }

    func oldest(max: Int) -> [TelemetryRecord] {
        noteCall()
        return locked {
            Array(byId.values.sorted { lhs, rhs in
                lhs.timeUnixMillis != rhs.timeUnixMillis
                    ? lhs.timeUnixMillis < rhs.timeUnixMillis
                    : Self.sequence(lhs.id) < Self.sequence(rhs.id)
            }.prefix(max))
        }
    }

    func remove(ids: [String]) {
        noteCall()
        locked { ids.forEach { byId[$0] = nil } }
    }

    func prune(now: Int64) -> PruneResult {
        noteCall()
        return locked {
            pruneLog.append(now)
            return scriptedPrune
        }
    }

    func count() -> Int {
        noteCall()
        return locked { byId.count }
    }

    private static func sequence(_ id: String) -> Int64 {
        id.split(separator: "-").last.flatMap { Int64($0) } ?? Int64.max
    }

    private func noteCall() {
        let label = String(cString: __dispatch_queue_get_label(nil))
        let call = Call(isMainThread: Thread.isMainThread, queueLabel: label)
        locked { callLog.append(call) }
    }

    private func locked<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
