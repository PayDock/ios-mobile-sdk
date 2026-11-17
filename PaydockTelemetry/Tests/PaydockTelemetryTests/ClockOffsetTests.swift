//
//  ClockOffsetTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import PaydockTelemetry
import XCTest

/// R_04: server time minus device time, 0 until the first measurement, only from a date in 2020–2100.
final class ClockOffsetTests: XCTestCase {

    private static let deviceNow: Int64 = 1_793_852_047_512

    private let clock = FixedClock(ClockOffsetTests.deviceNow)
    private lazy var offset = ClockOffset(clock: clock)

    func testOffset_IsZeroUntilTheFirstMeasurement() {
        XCTAssertEqual(offset.milliseconds, 0)
    }

    func testServerAhead_IsPositive() {
        offset.measure(serverDateMilliseconds: Self.deviceNow + 4_000)

        XCTAssertEqual(offset.milliseconds, 4_000)
    }

    func testServerBehind_IsNegative() {
        offset.measure(serverDateMilliseconds: Self.deviceNow - 90_000)

        XCTAssertEqual(offset.milliseconds, -90_000)
    }

    func testEachMeasurement_ReplacesTheLast_ReadingTheClockEachTime() {
        offset.measure(serverDateMilliseconds: Self.deviceNow + 4_000)
        clock.advance(by: 1_000)
        offset.measure(serverDateMilliseconds: Self.deviceNow + 1_000)

        XCTAssertEqual(offset.milliseconds, 0)
    }

    func testDateOutsideTheWindow_IsIgnored() {
        offset.measure(serverDateMilliseconds: Self.deviceNow + 4_000)
        offset.measure(serverDateMilliseconds: ClockOffset.minServerDateMilliseconds - 1)
        offset.measure(serverDateMilliseconds: ClockOffset.maxServerDateMilliseconds)
        offset.measure(serverDateMilliseconds: 0)

        XCTAssertEqual(offset.milliseconds, 4_000)
    }

    func testWindowEdges_AreMeasured() {
        offset.measure(serverDateMilliseconds: ClockOffset.minServerDateMilliseconds)
        XCTAssertEqual(offset.milliseconds, ClockOffset.minServerDateMilliseconds - Self.deviceNow)

        offset.measure(serverDateMilliseconds: ClockOffset.maxServerDateMilliseconds - 1)
        XCTAssertEqual(offset.milliseconds, ClockOffset.maxServerDateMilliseconds - 1 - Self.deviceNow)
    }

    func testWindow_Is2020To2100() {
        XCTAssertEqual(HttpDate.epochMilliseconds("Wed, 01 Jan 2020 00:00:00 GMT"), ClockOffset.minServerDateMilliseconds)
        XCTAssertEqual(HttpDate.epochMilliseconds("Fri, 01 Jan 2100 00:00:00 GMT"), ClockOffset.maxServerDateMilliseconds)
    }
}
