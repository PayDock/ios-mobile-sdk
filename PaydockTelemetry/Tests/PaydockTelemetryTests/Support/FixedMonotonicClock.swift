//
//  FixedMonotonicClock.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Gives the same elapsed time until a test advances it.
final class FixedMonotonicClock: MonotonicClock, @unchecked Sendable {
    private let lock = NSLock()
    private var current: Int64

    init(_ start: Int64 = 0) {
        current = start
    }

    func elapsed() -> Int64 {
        lock.lock()
        defer { lock.unlock() }
        return current
    }

    func advance(by milliseconds: Int64) {
        lock.lock()
        current += milliseconds
        lock.unlock()
    }
}
