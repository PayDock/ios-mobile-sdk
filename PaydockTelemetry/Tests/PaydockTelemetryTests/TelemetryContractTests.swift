//
//  TelemetryContractTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

final class TelemetryContractTests: XCTestCase {

    /// Implements only what the facade requires; that it compiles proves the facade requires nothing else.
    private struct FacadeOnly: Telemetry {
        var isActive: Bool { false }
        func report(_ event: TelemetryEvent) {}
    }

    func testNoEvent_HoldsARawErrorOrException() {
        XCTAssertFalse(rawErrorPaths(in: ("probe", NSError(domain: "SampleDomain", code: 1)), path: "probe").isEmpty)

        let events = Self.everyEvent()
        XCTAssertEqual(Set(events.map(Self.kind)).count, 4)
        XCTAssertEqual(Set(Self.everyNetworkError().map(Self.kind)).count, 3)

        for event in events {
            XCTAssertEqual(rawErrorPaths(in: event, path: "event"), [], "\(Self.kind(of: event)) holds a raw error")
        }
    }

    func testNoOpTelemetry_IsBothFacadeAndRuntime() {
        let facade: any Telemetry = NoOpTelemetry()
        let runtime: any TelemetryRuntime = NoOpTelemetry()

        XCTAssertFalse(facade.isActive)
        runtime.start()
    }

    func testFacade_DoesNotRefineTheRuntime() {
        let facade: any Telemetry = FacadeOnly()

        facade.report(.uncaughtException(error: TelemetryEvent.ErrorInfo(type: "Sample.Error", frames: [])))

        XCTAssertFalse((FacadeOnly() as Any) is any TelemetryRuntime)
    }

    func testReportedIntent_GivesBackTheSameEvent() {
        let event = TelemetryEvent.sdkError(error: TelemetryEvent.ErrorInfo(type: "Sample.Error", frames: []), errorCode: "SAMPLE")

        guard case let .reported(reported) = TelemetryIntent.reported(event) else {
            return XCTFail("TelemetryIntent.reported does not match .reported")
        }
        XCTAssertEqual(reported, event)
    }

    // MARK: - Fixtures

    private static func everyNetworkError() -> [TelemetryEvent.NetworkError] {
        let info = TelemetryEvent.ErrorInfo.from(URLError(.timedOut), frames: ["0 Sample 0x0000000100000000"])
        return [
            .httpStatus(code: 503),
            .transport(kind: .timeout, error: info),
            .decode(statusCode: 200, error: info)
        ]
    }

    private static func everyEvent() -> [TelemetryEvent] {
        let underlying = NSError(domain: "SampleDomain", code: 1)
        let exception = NSException(
            name: .invalidArgumentException,
            reason: "sample",
            userInfo: [NSUnderlyingErrorKey: underlying]
        )
        let info = TelemetryEvent.ErrorInfo.from(
            NSError(domain: "SampleDomain", code: 2, userInfo: [NSUnderlyingErrorKey: underlying]),
            frames: ["0 Sample 0x0000000100000000"]
        )
        let apiError = TelemetryEvent.APIError(status: "400", code: "sample_code", summaryCode: "sample", gatewayCodes: ["G1"])

        let fixed: [TelemetryEvent] = [
            .crash(error: .from(exception), source: .nsException, crashReason: "NSInvalidArgumentException", threadName: "main"),
            .uncaughtException(error: info, threadName: "worker", widget: "SampleWidget"),
            .sdkError(error: info, errorCode: "SAMPLE_CODE", widget: "SampleWidget")
        ]
        let failures: [TelemetryEvent] = everyNetworkError().map { failure in
            .networkFailure(
                method: .post,
                urlTemplate: "/v1/sample/{id}",
                serverAddress: "api-sandbox.paydock.com",
                failure: failure,
                attempt: 2,
                apiError: apiError,
                widget: "SampleWidget"
            )
        }
        return fixed + failures
    }

    /// Exhaustive, so a new case fails to compile here until it has a fixture.
    private static func kind(of event: TelemetryEvent) -> String {
        switch event {
        case .crash: return "crash"
        case .uncaughtException: return "uncaughtException"
        case .sdkError: return "sdkError"
        case .networkFailure: return "networkFailure"
        }
    }

    /// Exhaustive, so a new case fails to compile here until it has a fixture.
    private static func kind(of failure: TelemetryEvent.NetworkError) -> String {
        switch failure {
        case .httpStatus: return "httpStatus"
        case .transport: return "transport"
        case .decode: return "decode"
        }
    }

    private func rawErrorPaths(in value: Any, path: String) -> [String] {
        var paths: [String] = []
        if value is Error || value is NSException {
            paths.append(path)
        }
        for child in Mirror(reflecting: value).children {
            paths += rawErrorPaths(in: child.value, path: "\(path).\(child.label ?? "_")")
        }
        return paths
    }
}
