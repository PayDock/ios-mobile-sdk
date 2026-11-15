//
//  SendStampTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import PaydockTelemetry
import XCTest

final class SendStampTests: XCTestCase {

    private static let window = SendStamp.orderingWindowMilliseconds
    private static let occurred: Int64 = 1_793_830_203_000   // 2026-11-04T22:10:03.000Z

    private let record = TelemetryRecord(
        id: "3f2a1c9e-8b7d-4e6f-a5c4-1b2d3e4f5a6b-1",
        timeUnixMillis: occurred,
        severity: .fatal,
        body: "paydock.crash · signal · SIGSEGV",
        attributes: [
            TelemetryAttribute(key: "event.name", value: .string("paydock.crash")),
            TelemetryAttribute(key: "session.id", value: .string("3f2a1c9e-8b7d-4e6f-a5c4-1b2d3e4f5a6b")),
            TelemetryAttribute(key: "paydock.widget", value: .string("CardDetailsWidget")),
            TelemetryAttribute(key: "exception.type", value: .string("EXC_BAD_ACCESS"))
        ]
    )

    func testConstants() {
        XCTAssertEqual(SendStamp.orderingWindowMilliseconds, 1_800_000)
        XCTAssertEqual(SendStamp.occurredAtKey, "paydock.occurred_at")
    }

    func testInsideTheWindow_KeepsItsOwnTime() {
        let stamped = SendStamp.stamp(record, sentAt: Self.occurred + 60_000, clockOffsetMilliseconds: 0)

        XCTAssertEqual(stamped, record)
    }

    func testExactlyThirtyMinutes_Stays() {
        let stamped = SendStamp.stamp(record, sentAt: Self.occurred + Self.window, clockOffsetMilliseconds: 0)

        XCTAssertEqual(stamped.timeUnixMillis, Self.occurred)
        XCTAssertNil(stamped.value(SendStamp.occurredAtKey))
    }

    func testBeyondTheWindow_GetsTheSendTime_AndTheRealTimeInKeyOrder() {
        let sentAt = Self.occurred + Self.window + 1

        let stamped = SendStamp.stamp(record, sentAt: sentAt, clockOffsetMilliseconds: 0)

        XCTAssertEqual(stamped.timeUnixMillis, sentAt)
        XCTAssertEqual(stamped.value(SendStamp.occurredAtKey), .string("2026-11-04T22:10:03.000Z"))
        XCTAssertEqual(stamped.attributes.map(\.key),
                       ["event.name", "session.id", "paydock.widget", "paydock.occurred_at", "exception.type"])
        XCTAssertEqual(stamped.body, record.body)
        XCTAssertEqual(stamped.severity, record.severity)
        XCTAssertEqual(stamped.id, record.id)
    }

    func testPositiveOffset_CorrectsBothTimes() {
        let offset: Int64 = 5_000

        let inside = SendStamp.stamp(record, sentAt: Self.occurred + 60_000, clockOffsetMilliseconds: offset)
        XCTAssertEqual(inside.timeUnixMillis, Self.occurred + offset)

        let late = SendStamp.stamp(record, sentAt: Self.occurred + Self.window + 1, clockOffsetMilliseconds: offset)
        XCTAssertEqual(late.timeUnixMillis, Self.occurred + Self.window + 1 + offset)
        XCTAssertEqual(late.value(SendStamp.occurredAtKey), .string("2026-11-04T22:10:08.000Z"))
    }

    func testNegativeOffset_CorrectsBothTimes() {
        let offset: Int64 = -3_000

        let inside = SendStamp.stamp(record, sentAt: Self.occurred + Self.window, clockOffsetMilliseconds: offset)
        XCTAssertEqual(inside.timeUnixMillis, Self.occurred + offset)
        XCTAssertNil(inside.value(SendStamp.occurredAtKey))

        let late = SendStamp.stamp(record, sentAt: Self.occurred + 2 * Self.window, clockOffsetMilliseconds: offset)
        XCTAssertEqual(late.timeUnixMillis, Self.occurred + 2 * Self.window + offset)
        XCTAssertEqual(late.value(SendStamp.occurredAtKey), .string("2026-11-04T22:10:00.000Z"))
    }

    func testAnExistingOccurredAt_IsReplaced() {
        let previous = record.with(SendStamp.occurredAtKey, .string("2026-11-04T00:00:00.000Z"))

        let stamped = SendStamp.stamp(previous, sentAt: Self.occurred + 2 * Self.window, clockOffsetMilliseconds: 0)

        XCTAssertEqual(stamped.attributes.filter { $0.key == SendStamp.occurredAtKey }.count, 1)
        XCTAssertEqual(stamped.value(SendStamp.occurredAtKey), .string("2026-11-04T22:10:03.000Z"))
    }
}
