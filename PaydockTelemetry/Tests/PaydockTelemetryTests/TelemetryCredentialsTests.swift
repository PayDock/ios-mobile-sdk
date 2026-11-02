//
//  TelemetryCredentialsTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

final class TelemetryCredentialsTests: XCTestCase {

    private static let endpoint = "https://otlp.invalid/v1/logs"
    private static let sentinelAuthorization = "SENTINEL-synthetic-not-a-credential"

    private let credentials = TelemetryCredentials(endpoint: endpoint, authorization: sentinelAuthorization)

    func testDescription_HoldsTheEndpoint_AndNeverTheAuthorization() {
        assertRedacted(String(describing: credentials))
    }

    func testDebugDescription_HoldsTheEndpoint_AndNeverTheAuthorization() {
        assertRedacted(String(reflecting: credentials))
    }

    func testDump_HoldsTheEndpoint_AndNeverTheAuthorization() {
        var output = ""
        dump(credentials, to: &output)

        assertRedacted(output)
    }

    func testFields_KeepTheirValues() {
        XCTAssertEqual(credentials.endpoint, Self.endpoint)
        XCTAssertEqual(credentials.authorization, Self.sentinelAuthorization)
    }

    private func assertRedacted(_ rendered: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(rendered.contains(Self.endpoint), rendered, file: file, line: line)
        XCTAssertFalse(rendered.contains(Self.sentinelAuthorization), "The authorization is printed", file: file, line: line)
    }
}
