//
//  ApplePlatformInfoTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import PaydockTelemetry
import XCTest

final class ApplePlatformInfoTests: XCTestCase {

    func testOsVersionAndModelIdentifier_AreNotEmpty() {
        let platform = ApplePlatformInfo()

        XCTAssertFalse(platform.osVersion.isEmpty)
        XCTAssertFalse(platform.modelIdentifier.isEmpty)
    }

    func testOsVersion_IsMajorMinorWithAnOptionalPatch() {
        let parts = ApplePlatformInfo().osVersion.split(separator: ".")

        XCTAssertTrue((2...3).contains(parts.count), ApplePlatformInfo().osVersion)
        XCTAssertTrue(parts.allSatisfy { Int($0) != nil }, ApplePlatformInfo().osVersion)
    }

    func testAppDebuggable_IsTrue() {
        XCTAssertTrue(ApplePlatformInfo().appDebuggable)
    }
}
#endif
