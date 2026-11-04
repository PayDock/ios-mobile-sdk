//
//  RecordingRecordQueue.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// An in-memory FIFO that records every offer and drain.
final class RecordingRecordQueue: RecordQueue, @unchecked Sendable {
    private let lock = NSLock()
    private var records: [PendingRecord] = []
    private var offerLog: [PendingRecord] = []
    private var drainLog: [Int] = []

    var offered: [PendingRecord] { locked { offerLog } }
    var drainRequests: [Int] { locked { drainLog } }

    func offer(_ record: PendingRecord) {
        locked {
            records.append(record)
            offerLog.append(record)
        }
    }

    func drain(max: Int) -> [PendingRecord] {
        locked {
            drainLog.append(max)
            let drained = Array(records.prefix(max))
            records.removeFirst(drained.count)
            return drained
        }
    }

    func size() -> Int {
        locked { records.count }
    }

    private func locked<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}
