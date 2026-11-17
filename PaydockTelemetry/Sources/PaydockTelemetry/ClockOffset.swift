//
//  ClockOffset.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The gateway's clock minus the device's (R_04): 0 until the first measurement, then the latest one. One per runtime,
/// shared by the transport and the flush runner; in memory only, never persisted.
package final class ClockOffset: @unchecked Sendable {
    /// 2020-01-01T00:00:00Z.
    package static let minServerDateMilliseconds: Int64 = 1_577_836_800_000
    /// 2100-01-01T00:00:00Z.
    package static let maxServerDateMilliseconds: Int64 = 4_102_444_800_000

    private let clock: any Clock
    private let lock = NSLock()
    private var offset: Int64 = 0

    package init(clock: any Clock) {
        self.clock = clock
    }

    package var milliseconds: Int64 {
        lock.lock()
        defer { lock.unlock() }
        return offset
    }

    /// Ignored outside `[minServerDateMilliseconds, maxServerDateMilliseconds)`; otherwise reads `clock.now()` and
    /// replaces the offset with `serverDateMilliseconds - now`.
    package func measure(serverDateMilliseconds: Int64) {
        guard serverDateMilliseconds >= Self.minServerDateMilliseconds,
              serverDateMilliseconds < Self.maxServerDateMilliseconds else {
            return
        }
        let now = clock.now()
        lock.lock()
        offset = serverDateMilliseconds - now
        lock.unlock()
    }
}
