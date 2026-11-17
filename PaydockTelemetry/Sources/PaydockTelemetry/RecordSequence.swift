//
//  RecordSequence.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// One per session; the only source of record sequences. Behind an `NSLock`, so a crash handler can take an ID off
/// the telemetry queue.
package final class RecordSequence: @unchecked Sendable {
    private let lock = NSLock()
    private var last: Int64 = 0

    package init() {}

    /// 1, 2, 3, …
    package func next() -> Int64 {
        lock.lock()
        defer { lock.unlock() }
        last += 1
        return last
    }
}
