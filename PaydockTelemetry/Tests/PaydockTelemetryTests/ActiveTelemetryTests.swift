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

    private let dispatcher = ImmediateDispatcher()
    private let provider = FakeDeviceContextProvider()

    func testIsActive_IsTrue_AndKeepsCredentialsAndLevel() {
        let telemetry = makeTelemetry()

        XCTAssertTrue(telemetry.isActive)
        XCTAssertEqual(telemetry.credentials, TelemetryFixtures.credentials)
        XCTAssertEqual(telemetry.level, .errors)
    }

    func testInitialState_IsEnabled_AtTheLevel_WithTheSessionId() {
        let telemetry = makeTelemetry(idGenerator: SequentialIdGenerator(prefix: "session"))

        XCTAssertEqual(telemetry.sessionId, "session-0")
        XCTAssertEqual(telemetry.currentState(), TelemetryState(level: .errors, enabled: true, sessionId: "session-0"))
    }

    func testTwoInstances_HaveDifferentSessionIds() {
        let first = ActiveTelemetry(credentials: TelemetryFixtures.credentials, level: .all, deviceContextProvider: provider,
                                    dispatcher: dispatcher)
        let second = ActiveTelemetry(credentials: TelemetryFixtures.credentials, level: .all, deviceContextProvider: provider,
                                     dispatcher: dispatcher)

        XCTAssertNotEqual(first.sessionId, second.sessionId)
        XCTAssertFalse(first.sessionId.isEmpty)
    }

    func testStart_Twice_BuildsTheContextOnce() {
        let telemetry = makeTelemetry()
        XCTAssertNil(telemetry.resourceAttributes)

        telemetry.start()
        telemetry.start()

        XCTAssertEqual(provider.callCount, 1)
        XCTAssertEqual(telemetry.resourceAttributes, FakeDeviceContextProvider.attributes)
    }

    func testReport_RunsTheReducerOnTheDispatcher() {
        let telemetry = makeTelemetry(idGenerator: SequentialIdGenerator(prefix: "session"))

        telemetry.report(TelemetryFixtures.crash())

        let state = telemetry.currentState()
        XCTAssertEqual(state.queued, 1)
        XCTAssertEqual(state.nextSequence, 1)
        XCTAssertTrue(state.flushScheduled)
        XCTAssertEqual(dispatcher.delayedMilliseconds, [TelemetryReducer.flushIntervalMilliseconds])
    }

    /// MD-34 acceptance: a blocked queue never blocks the caller.
    func testReport_WithTheQueueBlocked_EveryCallReturnsWithinASecond() {
        let serial = SerialTelemetryDispatcher()
        let gate = DispatchSemaphore(value: 0)
        defer { gate.signal() }
        XCTAssertTrue(serial.post { gate.wait() })
        let telemetry = ActiveTelemetry(credentials: TelemetryFixtures.credentials, level: .all, deviceContextProvider: provider,
                                        dispatcher: serial)
        let event = TelemetryFixtures.sdkError()

        let started = Date()
        for _ in 0..<5_000 {
            telemetry.report(event)
        }
        let elapsed = Date().timeIntervalSince(started)

        XCTAssertLessThan(elapsed, 1.0)
        XCTAssertFalse(serial.post {}, "the blocked queue accepted more than its capacity")
    }

    /// R_12: every exported batch carries the installation ID, every record the instance's session ID.
    func testEndToEnd_EveryBatchCarriesTheInstallationId_AndEveryRecordTheSessionId() {
        let clock = FixedClock()
        let queue = RecordingRecordQueue()
        let store = RecordingDurableStore()
        let exporter = RecordingExporter()
        let telemetry = ActiveTelemetry(
            credentials: TelemetryFixtures.credentials,
            level: .all,
            deviceContextProvider: provider,
            clock: clock,
            dispatcher: dispatcher,
            ports: ActiveTelemetry.Ports(queue: queue, store: store, exporter: exporter)
        )
        telemetry.start()

        for _ in 0..<25 {
            telemetry.report(TelemetryFixtures.crash())
        }
        telemetry.report(TelemetryFixtures.sdkError())
        telemetry.report(TelemetryFixtures.sdkError())
        telemetry.report(TelemetryFixtures.networkFailure())
        clock.advance(by: TelemetryReducer.collapseWindowMilliseconds)
        dispatcher.runDelayed()

        let batches = exporter.batches
        let records = batches.flatMap(\.records)
        XCTAssertEqual(batches.count, 2)
        XCTAssertEqual(records.count, 27)
        XCTAssertEqual(Set(records.map(\.id)).count, records.count)
        for batch in batches {
            XCTAssertEqual(batch.resource.appInstallationId, FakeDeviceContextProvider.installationId)
            XCTAssertEqual(batch.resource.asMap()["app.installation.id"], .string(FakeDeviceContextProvider.installationId))
        }
        for record in records {
            XCTAssertEqual(record.sessionId, telemetry.sessionId)
            XCTAssertTrue(record.id.hasPrefix("\(telemetry.sessionId)-"), record.id)
        }
        XCTAssertEqual(records.first { $0.event == TelemetryFixtures.sdkError() }?.occurrences, 2)
        XCTAssertEqual(queue.size(), 0)
        XCTAssertFalse(store.saved.isEmpty)
        XCTAssertFalse(telemetry.currentState().flushScheduled)
    }

    private func makeTelemetry(idGenerator: any IdGenerator = RandomIdGenerator()) -> ActiveTelemetry {
        ActiveTelemetry(
            credentials: TelemetryFixtures.credentials,
            level: .errors,
            deviceContextProvider: provider,
            idGenerator: idGenerator,
            dispatcher: dispatcher
        )
    }
}
#endif
