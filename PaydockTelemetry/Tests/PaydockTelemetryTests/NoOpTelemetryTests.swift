//
//  NoOpTelemetryTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

final class NoOpTelemetryTests: XCTestCase {

    private let info = TelemetryEvent.ErrorInfo(type: "Sample.Error", frames: ["0 Sample 0x0000000100000000"])

    func testIsActive_IsFalse() {
        XCTAssertFalse(NoOpTelemetry().isActive)
    }

    func testReport_AcceptsOneEventOfEachKind_AndReturns() {
        let telemetry = NoOpTelemetry()
        let events: [TelemetryEvent] = [
            .crash(error: info, source: .nsException, crashReason: "NSInvalidArgumentException"),
            .uncaughtException(error: info),
            .sdkError(error: info, errorCode: "SAMPLE_CODE"),
            .networkFailure(
                method: .get,
                urlTemplate: "/v1/sample/{id}",
                serverAddress: "api-sandbox.paydock.com",
                failure: .httpStatus(code: 500)
            )
        ]

        for event in events {
            telemetry.report(event)
        }

        XCTAssertFalse(telemetry.isActive)
    }

    func testStart_ReturnsAndCanBeCalledTwice() {
        let telemetry = NoOpTelemetry()

        telemetry.start()
        telemetry.start()

        XCTAssertFalse(telemetry.isActive)
    }
}
