//
//  HttpDateTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import PaydockTelemetry
import XCTest

/// R_04: the gateway's `Date` header, IMF-fixdate only, by integer arithmetic.
final class HttpDateTests: XCTestCase {

    func testImfFixdate_IsEpochMilliseconds() {
        XCTAssertEqual(HttpDate.epochMilliseconds("Sun, 06 Nov 1994 08:49:37 GMT"), 784_111_777_000)
    }

    func testKnownDates() {
        XCTAssertEqual(HttpDate.epochMilliseconds("Thu, 01 Jan 1970 00:00:00 GMT"), 0)
        XCTAssertEqual(HttpDate.epochMilliseconds("Wed, 01 Jan 2020 00:00:00 GMT"), 1_577_836_800_000)
        XCTAssertEqual(HttpDate.epochMilliseconds("Thu, 29 Feb 2024 12:00:00 GMT"), 1_709_208_000_000)
        XCTAssertEqual(HttpDate.epochMilliseconds("Fri, 01 Jan 2100 00:00:00 GMT"), 4_102_444_800_000)
    }

    func testMalformed_IsNil() {
        let malformed = [
            "", "Sun, 06 Nov 1994 08:49:37", "Sunday, 06-Nov-94 08:49:37 GMT", "Sun Nov  6 08:49:37 1994",
            "Sun, 06 Nov 1994 08:49:37 UTC", "Xyz, 06 Nov 1994 08:49:37 GMT", "Sun, 06 Foo 1994 08:49:37 GMT",
            "Sun, 6 Nov 1994 08:49:37 GMT", "Sun, 06 Nov 1994 8:49:37 GMT", "Sun, 06 Nov 1994 24:00:00 GMT",
            "Sun, 06 Nov 1994 08:60:00 GMT", "Sun, 00 Nov 1994 08:49:37 GMT", "Tue, 30 Feb 2021 08:49:37 GMT",
            "Sat, 29 Feb 2023 00:00:00 GMT", "Sun, 31 Nov 1994 08:49:37 GMT", "Sun, 06 Nov 19a4 08:49:37 GMT",
            "Sun, 06 Nov 1994 08:49:37 GMT ", "7"
        ]
        for value in malformed {
            XCTAssertNil(HttpDate.epochMilliseconds(value), value)
        }
    }
}
