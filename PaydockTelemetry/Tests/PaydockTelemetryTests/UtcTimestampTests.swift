//
//  UtcTimestampTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import PaydockTelemetry
import XCTest

final class UtcTimestampTests: XCTestCase {

    func testEpoch() {
        XCTAssertEqual(UtcTimestamp.iso8601(0), "1970-01-01T00:00:00.000Z")
    }

    func testLeapDay() {
        XCTAssertEqual(UtcTimestamp.iso8601(1_709_210_096_789), "2024-02-29T12:34:56.789Z")
        XCTAssertEqual(UtcTimestamp.iso8601(951_868_800_000 - 1), "2000-02-29T23:59:59.999Z")
        XCTAssertEqual(UtcTimestamp.iso8601(951_868_800_000), "2000-03-01T00:00:00.000Z")
    }

    func testAContractTime() {
        XCTAssertEqual(UtcTimestamp.iso8601(1_793_830_203_000), "2026-11-04T22:10:03.000Z")
    }

    func testNegativeValues_RoundDownToThePreviousDay() {
        XCTAssertEqual(UtcTimestamp.iso8601(-1), "1969-12-31T23:59:59.999Z")
        XCTAssertEqual(UtcTimestamp.iso8601(-86_400_000), "1969-12-31T00:00:00.000Z")
        XCTAssertEqual(UtcTimestamp.iso8601(-2_203_891_200_001), "1900-02-28T23:59:59.999Z")
    }

    func testExtremes_DoNotTrap() {
        XCTAssertTrue(UtcTimestamp.iso8601(.min).hasSuffix("Z"))
        XCTAssertTrue(UtcTimestamp.iso8601(.max).hasSuffix("Z"))
    }
}
