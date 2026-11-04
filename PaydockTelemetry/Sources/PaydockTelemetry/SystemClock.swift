//
//  SystemClock.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The system clock, as UTC epoch milliseconds.
package struct SystemClock: Clock {
    package init() {}

    package func now() -> Int64 {
        Int64((Date().timeIntervalSince1970 * 1_000).rounded(.down))
    }
}
