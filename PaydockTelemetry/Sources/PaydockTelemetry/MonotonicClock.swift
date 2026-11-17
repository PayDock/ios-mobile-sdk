//
//  MonotonicClock.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Elapsed time that never jumps with the wall clock. Injected so the reducer's caller stays testable.
package protocol MonotonicClock: Sendable {
    /// Milliseconds since an arbitrary origin.
    func elapsed() -> Int64
}
