//
//  RetryPolicyTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import PaydockTelemetry
import XCTest

/// R_12: back-off from 5 s doubling to 60 s, jitter over the upper half, `Retry-After` honoured.
final class RetryPolicyTests: XCTestCase {

    func testDelay_DoublesFromTheBase_WithJitterOverTheUpperHalf() {
        let lowest = FixedRandom(.lowest)
        let highest = FixedRandom(.highest)
        let low = RetryPolicy(random: lowest.function)
        let high = RetryPolicy(random: highest.function)

        XCTAssertEqual((1...4).map { low.delayMilliseconds(failedAttempts: $0, retryAfterMilliseconds: nil) },
                       [2_500, 5_000, 10_000, 20_000])
        XCTAssertEqual((1...4).map { high.delayMilliseconds(failedAttempts: $0, retryAfterMilliseconds: nil) },
                       [5_000, 10_000, 20_000, 40_000])
        XCTAssertEqual(lowest.ranges, [0...2_500, 0...5_000, 0...10_000, 0...20_000])
    }

    func testDelay_IsCappedAtSixtySeconds() {
        let lowest = FixedRandom(.lowest)
        let low = RetryPolicy(random: lowest.function)
        let high = RetryPolicy(random: FixedRandom(.highest).function)

        XCTAssertEqual(low.delayMilliseconds(failedAttempts: 5, retryAfterMilliseconds: nil), 30_000)
        XCTAssertEqual(high.delayMilliseconds(failedAttempts: 5, retryAfterMilliseconds: nil), 60_000)
        XCTAssertEqual(high.delayMilliseconds(failedAttempts: 100, retryAfterMilliseconds: nil), 60_000)
        XCTAssertEqual(lowest.ranges, [0...30_000])
        let defaultPolicy = RetryPolicy()
        for attempts in 1...8 {
            XCTAssertLessThanOrEqual(defaultPolicy.delayMilliseconds(failedAttempts: attempts, retryAfterMilliseconds: nil),
                                     TelemetryLimits.retryMaxDelayMilliseconds)
        }
    }

    func testRetryAfter_IsHonoured_WhenLonger() {
        let policy = RetryPolicy(random: FixedRandom(.highest).function)

        XCTAssertEqual(policy.delayMilliseconds(failedAttempts: 1, retryAfterMilliseconds: 7_000), 7_000)
        XCTAssertEqual(policy.delayMilliseconds(failedAttempts: 1, retryAfterMilliseconds: 2_000), 5_000)
        XCTAssertEqual(policy.delayMilliseconds(failedAttempts: 1, retryAfterMilliseconds: 120_000), 120_000)
        XCTAssertEqual(policy.delayMilliseconds(failedAttempts: 1, retryAfterMilliseconds: 0), 5_000)
    }

    /// A `Retry-After` beyond an hour waits an hour, so a bad gateway answer can neither overflow the runner's next
    /// attempt time nor stop sending for the rest of the process.
    func testRetryAfter_IsCappedAtAnHour() {
        let policy = RetryPolicy(random: FixedRandom(.highest).function)
        let hour = TelemetryLimits.retryAfterMaxMilliseconds

        XCTAssertEqual(hour, 3_600_000)
        XCTAssertEqual(policy.delayMilliseconds(failedAttempts: 1, retryAfterMilliseconds: hour), hour)
        XCTAssertEqual(policy.delayMilliseconds(failedAttempts: 1, retryAfterMilliseconds: hour + 1), hour)
        XCTAssertEqual(policy.delayMilliseconds(failedAttempts: 1, retryAfterMilliseconds: Int64.max / 1_000 * 1_000), hour)
    }
}
