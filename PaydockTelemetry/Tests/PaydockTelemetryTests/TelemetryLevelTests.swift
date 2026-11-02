//
//  TelemetryLevelTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

final class TelemetryLevelTests: XCTestCase {

    func testAbsentOrBlank_IsAll() {
        XCTAssertEqual(TelemetryLevel.parse(nil), .all)
        XCTAssertEqual(TelemetryLevel.parse(""), .all)
        XCTAssertEqual(TelemetryLevel.parse("  "), .all)
    }

    func testLevelName_CaseInsensitiveAndTrimmed_IsThatLevel() {
        XCTAssertEqual(TelemetryLevel.parse("off"), .off)
        XCTAssertEqual(TelemetryLevel.parse("ERRORS"), .errors)
        XCTAssertEqual(TelemetryLevel.parse(" all "), .all)
    }

    func testUnknownName_IsOff() {
        XCTAssertEqual(TelemetryLevel.parse("verbose"), .off)
    }
}
