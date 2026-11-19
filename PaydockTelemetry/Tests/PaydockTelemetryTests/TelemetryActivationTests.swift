//
//  TelemetryActivationTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_02: active with a non-blank endpoint, inactive otherwise.
final class TelemetryActivationTests: XCTestCase {

    func testNilEndpoint_IsInactive() {
        XCTAssertFalse(TelemetryActivation.isActive(endpoint: nil))
    }

    func testEmptyOrBlankEndpoint_IsInactive() {
        for endpoint in ["", " ", "\t\n "] {
            XCTAssertFalse(TelemetryActivation.isActive(endpoint: endpoint), "endpoint: \(endpoint.debugDescription)")
        }
    }

    func testUrlEndpoint_IsActive() {
        XCTAssertTrue(TelemetryActivation.isActive(endpoint: TelemetryFixtures.endpoint))
        XCTAssertTrue(TelemetryActivation.isActive(endpoint: " \(TelemetryFixtures.endpoint)\n"))
    }
}
