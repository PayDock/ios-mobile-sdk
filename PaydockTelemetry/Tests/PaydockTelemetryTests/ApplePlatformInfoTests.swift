//
//  ApplePlatformInfoTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

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

    /// R_07: follows the build configuration, true in debug and false in release.
    func testAppDebuggable_FollowsTheBuildConfiguration() {
        #if DEBUG
        XCTAssertTrue(ApplePlatformInfo().appDebuggable)
        #else
        XCTAssertFalse(ApplePlatformInfo().appDebuggable)
        #endif
    }
}
