//
//  FixedRandom.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// A random source for `RetryPolicy` that always picks one end of the range and records every range asked for.
final class FixedRandom: @unchecked Sendable {
    enum Pick { case lowest, highest }

    private let lock = NSLock()
    private let pick: Pick
    private var rangeLog: [ClosedRange<Int64>] = []

    init(_ pick: Pick = .lowest) {
        self.pick = pick
    }

    var ranges: [ClosedRange<Int64>] {
        lock.lock()
        defer { lock.unlock() }
        return rangeLog
    }

    /// The closure to hand to `RetryPolicy(random:)`.
    var function: @Sendable (ClosedRange<Int64>) -> Int64 {
        { [self] range in next(in: range) }
    }

    private func next(in range: ClosedRange<Int64>) -> Int64 {
        lock.lock()
        defer { lock.unlock() }
        rangeLog.append(range)
        return pick == .lowest ? range.lowerBound : range.upperBound
    }
}
