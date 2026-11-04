//
//  FixedClock.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Gives the same time until a test advances it.
final class FixedClock: Clock, @unchecked Sendable {
    private let lock = NSLock()
    private var current: Int64

    init(_ start: Int64 = 1_700_000_000_000) {
        current = start
    }

    func now() -> Int64 {
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
