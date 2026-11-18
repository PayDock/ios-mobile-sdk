//
//  SystemMonotonicClock.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// `clock_gettime_nsec_np(CLOCK_MONOTONIC)` in milliseconds: counts during sleep, and is not a boot-time
/// required-reason API (D16).
package struct SystemMonotonicClock: MonotonicClock {
    package init() {}

    package func elapsed() -> Int64 {
        Int64(clock_gettime_nsec_np(CLOCK_MONOTONIC) / 1_000_000)
    }
}
