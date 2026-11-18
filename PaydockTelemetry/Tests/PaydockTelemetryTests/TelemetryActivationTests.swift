//
//  TelemetryActivationTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_02: active with a non-blank endpoint and a level other than off.
final class TelemetryActivationTests: XCTestCase {

    private static let credentials = TelemetryCredentials(
        endpoint: "https://otlp.invalid/v1/logs",
        authorization: "synthetic-not-a-credential"
    )

    func testTwoInputTable_IsActiveOnlyWithCredentialsAndALevelOtherThanOff() {
        var rows = 0
        for credentials in [Self.credentials, nil] {
            for level in [TelemetryLevel.all, .errors, .off] {
                let expected = credentials != nil && level != .off
                XCTAssertEqual(
                    TelemetryActivation.isActive(credentials: credentials, level: level),
                    expected,
                    "credentials: \(credentials != nil), level: \(level)"
                )
                rows += 1
            }
        }
        XCTAssertEqual(rows, 6)
    }

    func testEmptyAuthorization_IsActive() {
        let credentials = TelemetryCredentials(endpoint: "https://otlp.invalid/v1/logs", authorization: "")

        XCTAssertTrue(TelemetryActivation.isActive(credentials: credentials, level: .all))
    }

    func testBlankAuthorization_IsActive() {
        let credentials = TelemetryCredentials(endpoint: "https://otlp.invalid/v1/logs", authorization: "  \n")

        XCTAssertTrue(TelemetryActivation.isActive(credentials: credentials, level: .errors))
    }

    func testEmptyOrBlankEndpoint_IsInactive() {
        for endpoint in ["", " ", "\t\n "] {
            let credentials = TelemetryCredentials(endpoint: endpoint, authorization: "synthetic-not-a-credential")

            XCTAssertFalse(TelemetryActivation.isActive(credentials: credentials, level: .all), "endpoint: \(endpoint.debugDescription)")
        }
    }
}
