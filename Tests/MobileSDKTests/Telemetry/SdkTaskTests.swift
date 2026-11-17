//
//  SdkTaskTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest
@testable import MobileSDK
import PaydockTelemetry

final class SdkTaskTests: XCTestCase {

    private let telemetry = RecordingTelemetry()

    override func setUp() {
        super.setUp()
        TelemetryBinding.bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
    }

    override func tearDown() {
        TelemetryBinding.bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
        super.tearDown()
    }

    func testTheWork_RunsOnTheMainActor_AndToCompletion() async {
        bindRecording()
        let steps = StepLog()

        await SdkTask.run(widget: .zip) {
            steps.append("start", onMain: isOnMainThread())
            await Task.yield()
            steps.append("end", onMain: isOnMainThread())
        }.value

        XCTAssertEqual(steps.names, ["start", "end"])
        XCTAssertEqual(steps.onMain, [true, true])
        XCTAssertEqual(telemetry.reports, [])
    }

    func testAThrownError_IsReportedOnceAsUncaught_WithTheWidget() async throws {
        bindRecording()

        await SdkTask.run(widget: .afterpay) {
            throw SampleSwiftError()
        }.value

        XCTAssertEqual(telemetry.reports.count, 1)
        let report = try XCTUnwrap(telemetry.reports.first)
        XCTAssertEqual(report.event, .uncaughtException(
            error: TelemetryEvent.ErrorInfo(type: "MobileSDKTests.SampleSwiftError", frames: []),
            widget: "AfterpayWidget"
        ))
        let site = try XCTUnwrap(report.site)
        XCTAssertFalse(site.returnAddresses.isEmpty)
        XCTAssertEqual(site.threadName, "main")
    }

    func testACancellation_IsNotReported() async {
        bindRecording()

        await SdkTask.run(widget: .afterpay) {
            throw CancellationError()
        }.value

        XCTAssertEqual(telemetry.reports, [])
    }

    func testWithTheNoOpBound_TheWorkStillRuns_AndNothingIsReported() async {
        let steps = StepLog()

        await SdkTask.run(widget: .payPal) {
            steps.append("ran", onMain: isOnMainThread())
            throw SampleSwiftError()
        }.value

        XCTAssertEqual(steps.names, ["ran"])
        XCTAssertTrue(TelemetryBinding.current is NoOpTelemetry)
        XCTAssertEqual(telemetry.reports, [])
    }

    func testANonThrowingBody_ReportsNothing() async {
        bindRecording()

        await SdkTask.run(widget: nil) {}.value

        XCTAssertEqual(telemetry.reports, [])
    }

    private func bindRecording() {
        TelemetryBinding.bind(TelemetrySelection(telemetry: telemetry, runtime: NoOpTelemetry()))
    }
}

/// What the work did, in order, and whether each step ran on the main thread. Thread-safe.
private final class StepLog: @unchecked Sendable {
    private let lock = NSLock()
    private var steps: [(name: String, onMain: Bool)] = []

    var names: [String] { lock.withLock { steps.map(\.name) } }
    var onMain: [Bool] { lock.withLock { steps.map(\.onMain) } }

    func append(_ name: String, onMain: Bool) {
        lock.withLock { steps.append((name, onMain)) }
    }
}

/// `Thread.isMainThread`, read from a synchronous context.
private func isOnMainThread() -> Bool {
    Thread.isMainThread
}
