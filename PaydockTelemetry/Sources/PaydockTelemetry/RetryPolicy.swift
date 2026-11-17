//
//  RetryPolicy.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Back-off with jitter that honours `Retry-After` (R_12).
package struct RetryPolicy: Sendable {
    private let random: @Sendable (ClosedRange<Int64>) -> Int64

    package init(random: @escaping @Sendable (ClosedRange<Int64>) -> Int64 = { Int64.random(in: $0) }) {
        self.random = random
    }

    /// `d = min(retryMaxDelayMilliseconds, retryBaseDelayMilliseconds × 2^(failedAttempts − 1))`, then
    /// `max(d / 2 + random(0...(d / 2)), min(retryAfterMilliseconds ?? 0, retryAfterMaxMilliseconds))`.
    package func delayMilliseconds(failedAttempts: Int, retryAfterMilliseconds: Int64?) -> Int64 {
        var delay = TelemetryLimits.retryBaseDelayMilliseconds
        var doublings = max(0, failedAttempts - 1)
        while doublings > 0, delay < TelemetryLimits.retryMaxDelayMilliseconds {
            delay *= 2
            doublings -= 1
        }
        delay = min(TelemetryLimits.retryMaxDelayMilliseconds, delay)
        let half = delay / 2
        let retryAfter = min(max(0, retryAfterMilliseconds ?? 0), TelemetryLimits.retryAfterMaxMilliseconds)
        return max(half + random(0...half), retryAfter)
    }
}
