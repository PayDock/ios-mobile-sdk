//
//  ClockTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

final class ClockTests: XCTestCase {

    func testSystemClock_IsUtcEpochMilliseconds() {
        let expected = Int64(Date().timeIntervalSince1970 * 1_000)

        XCTAssertLessThan(abs(SystemClock().now() - expected), 1_000)
    }

    func testRandomIdGenerator_GivesLowerCasedUuids_ThatDiffer() {
        let generator = RandomIdGenerator()
        let first = generator.newId()

        XCTAssertNotNil(UUID(uuidString: first))
        XCTAssertEqual(first, first.lowercased())
        XCTAssertNotEqual(first, generator.newId())
    }
}
