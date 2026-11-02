//
//  TelemetryActivationTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

final class TelemetryActivationTests: XCTestCase {

    private static let credentials = TelemetryCredentials(
        endpoint: "https://otlp.invalid/v1/logs",
        authorization: "synthetic-not-a-credential"
    )
    private static let paydockHost = "com.paydock.multitenant.sandbox"
    private static let merchantHost = "com.merchant.shop"

    func testTruthTable_IsActiveOnlyWhenEveryConditionHolds() {
        var rows = 0
        for credentials in [Self.credentials, nil] {
            for isSandbox in [true, false] {
                for level in [TelemetryLevel.all, .off] {
                    for host in [Self.paydockHost, Self.merchantHost] {
                        let expected = credentials != nil && isSandbox && level == .all && host == Self.paydockHost
                        let actual = TelemetryActivation.isActive(
                            credentials: credentials,
                            isSandbox: isSandbox,
                            level: level,
                            hostBundleIdentifier: host
                        )
                        XCTAssertEqual(
                            actual,
                            expected,
                            "credentials: \(credentials != nil), sandbox: \(isSandbox), level: \(level), host: \(host)"
                        )
                        rows += 1
                    }
                }
            }
        }
        XCTAssertEqual(rows, 16)
    }

    func testErrorsLevel_IsActive() {
        XCTAssertTrue(isActive(level: .errors, host: Self.paydockHost))
    }

    func testNilHost_IsInactive() {
        XCTAssertFalse(isActive(level: .all, host: nil))
    }

    func testHostThatOnlyStartsLikePaydock_IsInactive() {
        XCTAssertFalse(isActive(level: .all, host: "com.paydockx.app"))
    }

    func testPaydockHostPrefix() {
        XCTAssertEqual(TelemetryActivation.paydockHostPrefix, "com.paydock.")
    }

    private func isActive(level: TelemetryLevel, host: String?) -> Bool {
        TelemetryActivation.isActive(
            credentials: Self.credentials,
            isSandbox: true,
            level: level,
            hostBundleIdentifier: host
        )
    }
}
