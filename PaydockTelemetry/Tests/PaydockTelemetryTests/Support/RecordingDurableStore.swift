//
//  RecordingDurableStore.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// An in-memory store, upserting by record id, that records every save, crash save and prune, answers prune with a
/// set result and records the thread and queue label of every call. `holdLock()` takes the store's lock on a thread of
/// its own until `releaseLock()`, so a crash save gives up after its timeout.
final class RecordingDurableStore: DurableStore, @unchecked Sendable {
    struct Call {
        let isMainThread: Bool
        let queueLabel: String
    }

    private let lock = NSLock()
    private let holder = LockHolder()
    private var crashSaveLog: [TelemetryRecord] = []
    private var callLog: [Call] = []
    private var byId: [String: TelemetryRecord] = [:]
    private var saveLog: [TelemetryRecord] = []
    private var pruneLog: [Int64] = []
    private var scriptedPrune = PruneResult()

    var saved: [TelemetryRecord] { locked { saveLog } }
    var crashSaved: [TelemetryRecord] { locked { crashSaveLog } }
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

    /// Noted only once it holds the lock: noting takes the lock too.
    func saveCrash(_ record: TelemetryRecord, timeout: TimeInterval) -> Bool {
        let call = currentCall()
        guard lock.lock(before: Date(timeIntervalSinceNow: timeout)) else {
            return false
        }
        defer { lock.unlock() }
        callLog.append(call)
        byId[record.id] = record
        crashSaveLog.append(record)
        return true
    }

    /// Takes the store's lock on another thread and returns once it holds it.
    func holdLock() {
        holder.hold(lock)
    }

    /// Lets the holding thread release the lock, and waits until it has.
    func releaseLock() {
        holder.release()
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
        let call = currentCall()
        locked { callLog.append(call) }
    }

    private func currentCall() -> Call {
        Call(isMainThread: Thread.isMainThread, queueLabel: String(cString: __dispatch_queue_get_label(nil)))
    }

    private func locked<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
