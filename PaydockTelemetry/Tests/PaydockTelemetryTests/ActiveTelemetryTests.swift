//
//  ActiveTelemetryTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation
import PaydockTelemetry
import XCTest

final class ActiveTelemetryTests: XCTestCase {

    private let telemetry = ActiveTelemetry(
        credentials: TelemetryCredentials(endpoint: "https://otlp.invalid/v1/logs", authorization: "synthetic-not-a-credential"),
        level: .all
    )

    func testIsActive_IsTrue() {
        XCTAssertTrue(telemetry.isActive)
    }

    func testReport_Returns() {
        telemetry.report(.sdkError(error: TelemetryEvent.ErrorInfo(type: "Sample.Error", frames: []), errorCode: "SAMPLE_CODE"))

        XCTAssertTrue(telemetry.isActive)
    }

    func testStart_ReturnsAndCanBeCalledTwice() {
        telemetry.start()
        telemetry.start()

        XCTAssertTrue(telemetry.isActive)
    }
}
#endif
