//
//  ActiveTelemetryTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib
import PaydockTelemetry
import XCTest

final class ActiveTelemetryTests: XCTestCase {

    /// Gives the same session ID every time.
    private struct FixedIdGenerator: IdGenerator {
        let id: String

        func newId() -> String { id }
    }

    /// Blocks every export until the test opens the gate, and says when the first one has begun.
    private final class GatedExporter: Exporter, @unchecked Sendable {
        let entered = DispatchSemaphore(value: 0)
        let gate = DispatchSemaphore(value: 0)

        func export(_ batch: ExportBatch) -> ExportResult {
            entered.signal()
            gate.wait()
            return .success(rejectedRecords: 0)
        }
    }

    private final class Flags: @unchecked Sendable {
        private let lock = NSLock()
        private var items: [Int] = []

        var values: [Int] {
            lock.lock()
            defer { lock.unlock() }
            return items
        }

        func append(_ value: Int) {
            lock.lock()
            items.append(value)
            lock.unlock()
        }
    }

    private static let sessionId = "7d1c3a9e-5b2f-4e8a-9c6d-0f4b8a2e1d37"
    private static let earlierSessionId = "0b6f2c4e-93a1-4d7e-8f25-6c1d9e3a7b40"
    private static let now: Int64 = 1_793_852_047_512
    private static let twoHours: Int64 = 7_200_000

    private let dispatcher = ImmediateDispatcher()
    private let provider = FakeDeviceContextProvider()
    private let clock = FixedClock(ActiveTelemetryTests.now)
    private let store = RecordingDurableStore()
    private let lifecycle = RecordingAppLifecycle()
    private let connection = RecordingConnectionMonitor()

    // MARK: - Identity and state

    func testIsActive_IsTrue_AndKeepsTheEndpoint() {
        let telemetry = makeTelemetry()

        XCTAssertTrue(telemetry.isActive)
        XCTAssertEqual(telemetry.endpoint, TelemetryFixtures.endpoint)
    }

    func testInitialState_IsEnabled_WithTheSessionId() {
        let telemetry = makeTelemetry()

        XCTAssertEqual(telemetry.sessionId, Self.sessionId)
        XCTAssertEqual(telemetry.currentState(), TelemetryState(enabled: true, sessionId: Self.sessionId))
    }

    func testTwoInstances_HaveDifferentSessionIds() {
        let first = ActiveTelemetry(endpoint: TelemetryFixtures.endpoint, deviceContextProvider: provider,
                                    dispatcher: dispatcher)
        let second = ActiveTelemetry(endpoint: TelemetryFixtures.endpoint, deviceContextProvider: provider,
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

    func testReport_RunsTheReducerOnTheDispatcher_WithIdsFromTheSessionsSequence() {
        let telemetry = makeTelemetry()

        telemetry.report(TelemetryFixtures.crash())

        let state = telemetry.currentState()
        XCTAssertEqual(state.pending, 1)
        XCTAssertEqual(state.createdInWindow, 1)
        XCTAssertTrue(state.flushScheduled)
        XCTAssertEqual(dispatcher.delayedMilliseconds, [TelemetryLimits.flushIntervalMilliseconds])
        XCTAssertEqual(store.saved.map(\.id), ["\(Self.sessionId)-1"])
        XCTAssertEqual(telemetry.sequence.next(), 2, "the record did not take its ID from the session's sequence")
    }

    /// MD-34 acceptance: a blocked queue never blocks the caller.
    func testReport_WithTheQueueBlocked_EveryCallReturnsWithinASecond() {
        let serial = SerialTelemetryDispatcher()
        let gate = DispatchSemaphore(value: 0)
        defer { gate.signal() }
        XCTAssertTrue(serial.post { gate.wait() })
        let telemetry = ActiveTelemetry(endpoint: TelemetryFixtures.endpoint, deviceContextProvider: provider,
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

    // MARK: - Widgets opened (R_09)

    func testTwoOpeningsOfOneWidget_StoreOneRecord() {
        let telemetry = makeTelemetry()

        telemetry.report(.widgetOpened(widget: "CardDetailsWidget"))
        telemetry.report(.widgetOpened(widget: "CardDetailsWidget"), site: ReportSite.capture())

        XCTAssertEqual(store.saved.count, 1)
        XCTAssertEqual(store.saved.first?.value("paydock.widget"), .string("CardDetailsWidget"))
        XCTAssertEqual(telemetry.currentState().openedWidgets, ["CardDetailsWidget"])
    }

    func testANewActiveTelemetry_StoresTheWidgetAgain() {
        makeTelemetry().report(.widgetOpened(widget: "CardDetailsWidget"))

        makeTelemetry().report(.widgetOpened(widget: "CardDetailsWidget"))

        XCTAssertEqual(store.saved.filter { $0.value("paydock.widget") == .string("CardDetailsWidget") }.count, 2)
    }

    // MARK: - Threads

    /// R_14: every store and transport call runs on the `com.paydock.telemetry` queue, never the main thread.
    func testEveryStoreAndTransportCall_RunsOnTheTelemetryQueue_NeverTheMainThread() {
        let serial = SerialTelemetryDispatcher()
        let transport = RecordingTransport()
        let telemetry = makeTelemetry(
            exporter: OtlpExporter(transport: transport),
            dispatcher: serial
        )
        XCTAssertTrue(Thread.isMainThread)

        telemetry.start()
        telemetry.report(TelemetryFixtures.crash())
        for index in 1..<TelemetryLimits.flushThreshold {
            telemetry.report(distinct(index))
        }
        waitUntil { transport.calls.count == 1 }
        drain(serial)

        XCTAssertEqual(transport.calls.count, 1)
        XCTAssertFalse(store.calls.isEmpty)
        for call in store.calls {
            XCTAssertFalse(call.isMainThread)
            XCTAssertEqual(call.queueLabel, SerialTelemetryDispatcher.label)
        }
        for call in transport.calls {
            XCTAssertFalse(call.isMainThread)
            XCTAssertEqual(call.queueLabel, SerialTelemetryDispatcher.label)
        }
    }

    // MARK: - Lifecycle and connection monitor

    func testLifecycleAndConnectionMonitor_AreRegisteredOnce_ByStartOnly() {
        let telemetry = makeTelemetry()

        telemetry.report(TelemetryFixtures.crash())
        dispatcher.runDelayed()
        XCTAssertEqual(lifecycle.registerCount, 0)
        XCTAssertEqual(connection.startCount, 0)

        telemetry.start()
        telemetry.start()

        XCTAssertEqual(lifecycle.registerCount, 1)
        XCTAssertEqual(connection.startCount, 1)
    }

    func testRecords_CarryTheConnectionType_AtTheirCreation() {
        let telemetry = makeTelemetry()
        telemetry.start()

        telemetry.report(TelemetryFixtures.crash())
        connection.connectionType = .cell
        telemetry.report(TelemetryFixtures.crash())

        XCTAssertEqual(store.saved.map { $0.value("network.connection.type") }, [.string("unknown"), .string("cell")])
    }

    /// R_10: the background callback exports at once, then calls `finished` in the same task.
    func testBackgroundCallback_Exports_ThenCallsFinished() {
        let exporter = ScriptedExporter()
        let telemetry = makeTelemetry(exporter: exporter)
        telemetry.start()
        store.save(stored(1, sessionId: Self.sessionId, at: Self.now - 1_000))
        let batchesWhenFinished = Flags()

        XCTAssertTrue(lifecycle.enterBackground { batchesWhenFinished.append(exporter.batches.count) })
        XCTAssertEqual(batchesWhenFinished.values, [], "finished was called before the export ran")
        XCTAssertEqual(dispatcher.delayedMilliseconds, [0])
        dispatcher.runDelayed()

        XCTAssertEqual(exporter.batchIds, [["\(Self.sessionId)-1"]])
        XCTAssertEqual(batchesWhenFinished.values, [1])
        XCTAssertEqual(store.count(), 0)
        XCTAssertEqual(telemetry.currentState().lastExport, Self.now)
    }

    // MARK: - Sending

    /// R_10: start counts the stored records and flushes at once, so an earlier run's records go before this run's.
    func testStart_FlushesStoredRecords_EarlierRunFirst() {
        store.save(stored(2, sessionId: Self.earlierSessionId, at: Self.now - 20_000))
        store.save(stored(1, sessionId: Self.earlierSessionId, at: Self.now - 30_000))
        let exporter = ScriptedExporter()
        let telemetry = makeTelemetry(exporter: exporter)

        telemetry.start()
        telemetry.report(TelemetryFixtures.crash())
        dispatcher.runDelayed()

        XCTAssertEqual(exporter.batchIds, [
            ["\(Self.earlierSessionId)-1", "\(Self.earlierSessionId)-2"],
            ["\(Self.sessionId)-1"]
        ])
        XCTAssertEqual(store.count(), 0)
    }

    /// R_11: a late stored record goes out with the send time and `paydock.occurred_at`, both corrected by the ports'
    /// offset; the stored record is unchanged.
    func testALateStoredRecord_IsSentStamped_WithThePortsOffset() throws {
        let offset = ClockOffset(clock: clock)
        offset.measure(serverDateMilliseconds: Self.now + 5_000)
        let late = stored(1, sessionId: Self.earlierSessionId, at: Self.now - Self.twoHours)
        store.save(late)
        let exporter = ScriptedExporter()
        let telemetry = makeTelemetry(exporter: exporter, clockOffset: offset)

        telemetry.start()

        let sent = try XCTUnwrap(exporter.batches.first?.records.first)
        XCTAssertEqual(sent.id, late.id)
        XCTAssertEqual(sent.timeUnixMillis, Self.now + 5_000)
        XCTAssertEqual(sent.value(SendStamp.occurredAtKey), .string(UtcTimestamp.iso8601(Self.now - Self.twoHours + 5_000)))
        XCTAssertEqual(store.saved, [late])
    }

    /// MD-36 acceptance: every batch carries the installation ID and every record its session ID.
    func testEveryBatch_CarriesTheInstallationId_AndEveryRecordItsSessionId() {
        let exporter = ScriptedExporter()
        let telemetry = makeTelemetry(exporter: exporter)
        telemetry.start()

        for index in 1...45 {
            telemetry.report(distinct(index))
        }
        telemetry.report(.dropped(reason: .rateLimit, count: 1))
        dispatcher.runDelayed()

        XCTAssertEqual(exporter.batches.map(\.records.count), [20, 20, 5])
        XCTAssertEqual(exporter.batchIds.flatMap { $0 }, (1...45).map { "\(Self.sessionId)-\($0)" })
        for batch in exporter.batches {
            XCTAssertEqual(batch.resource.appInstallationId, FakeDeviceContextProvider.installationId)
            for record in batch.records {
                XCTAssertEqual(record.value("session.id"), .string(Self.sessionId))
                XCTAssertEqual(record.value("log.record.uid"), .string(record.id))
            }
        }
        let state = telemetry.currentState()
        XCTAssertEqual(state.pending, 0)
        XCTAssertFalse(state.flushScheduled)
        XCTAssertNotNil(state.lastExport)
    }

    /// R_12: 401 stops sending for the rest of the process.
    func testATransportThatAlwaysAnswers401_SendsOnce_ThenStops() {
        let transport = RecordingTransport(fallback: .httpError(status: 401, retryAfterMilliseconds: nil))
        let telemetry = makeTelemetry(exporter: OtlpExporter(transport: transport))
        telemetry.start()

        for index in 1...25 {
            telemetry.report(distinct(index))
        }
        dispatcher.runDelayed()
        for index in 26...50 {
            telemetry.report(distinct(index))
        }
        telemetry.report(distinct(51))
        dispatcher.runDelayed()

        XCTAssertEqual(transport.calls.count, 1)
        let state = telemetry.currentState()
        XCTAssertTrue(state.exportStopped)
        XCTAssertFalse(state.flushScheduled)
        XCTAssertEqual(store.count(), 51)
    }

    /// Reports queued behind a slow send are counted in pending once the flush ends.
    func testReportsQueuedBehindASlowSend_AreCountedInPending_AfterTheFlush() {
        let serial = SerialTelemetryDispatcher()
        let exporter = GatedExporter()
        store.save(stored(1, sessionId: Self.earlierSessionId, at: Self.now - 1_000))
        let telemetry = makeTelemetry(exporter: exporter, dispatcher: serial)

        telemetry.start()
        XCTAssertEqual(exporter.entered.wait(timeout: .now() + 5), .success)
        for index in 1...3 {
            telemetry.report(distinct(index))
        }
        exporter.gate.signal()
        drain(serial)

        let state = telemetry.currentState()
        XCTAssertEqual(state.pending, 3)
        XCTAssertTrue(state.flushScheduled)
        XCTAssertEqual(store.count(), 3)
    }

    // MARK: - Disk

    /// R_15: an active runtime that records nothing creates no telemetry directory.
    func testActiveButIdle_CreatesNoTelemetryDirectory() throws {
        let temporary = try TemporaryDirectory()
        addTeardownBlock { temporary.remove() }
        let directory = temporary.child(FileDurableStore.directoryName)
        let telemetry = makeTelemetry(store: FileDurableStore(directory: { directory }))

        telemetry.start()
        lifecycle.enterBackground {}
        dispatcher.runDelayed()

        XCTAssertFalse(FileManager.default.fileExists(atPath: directory.path))
        XCTAssertEqual(telemetry.currentState().pending, 0)
    }

    /// R_05: a record survives process death; a second runtime on the same store directory sends it.
    func testARecordSurvivesProcessDeath_ASecondRuntimeOnTheSameDirectorySendsIt() throws {
        let temporary = try TemporaryDirectory()
        addTeardownBlock { temporary.remove() }
        let directory = temporary.child(FileDurableStore.directoryName)
        var first: ActiveTelemetry? = makeTelemetry(
            store: FileDurableStore(directory: { directory }),
            exporter: ScriptedExporter(fallback: .retry(retryAfterMilliseconds: nil))
        )
        first?.start()
        first?.report(TelemetryFixtures.crash())
        first = nil

        let exporter = ScriptedExporter()
        let second = ActiveTelemetry(
            endpoint: TelemetryFixtures.endpoint,
            deviceContextProvider: provider,
            clock: clock,
            monotonic: FixedMonotonicClock(),
            dispatcher: ImmediateDispatcher(),
            ports: ActiveTelemetry.Ports(store: FileDurableStore(directory: { directory }), exporter: exporter)
        )
        second.start()

        XCTAssertNotEqual(second.sessionId, Self.sessionId)
        XCTAssertEqual(exporter.batchIds, [["\(Self.sessionId)-1"]])
        XCTAssertEqual(FileDurableStore(directory: { directory }).count(), 0)
    }

    /// R_09, end to end: a full store loses a record while the threshold export sends the reason's notice; the drop
    /// starts a new notice, so no notice id is ever sent twice.
    func testADropCountedWhileItsNoticeIsSent_StartsANewNotice_TheSentOneIsNeverSentAgain() {
        let overflowing = OverflowingStore()
        let exporter = ScriptedExporter()
        let telemetry = makeTelemetry(store: overflowing, exporter: exporter)

        overflowing.loseOneOnNextPrune()
        telemetry.report(distinct(0))
        for index in 1..<(TelemetryLimits.flushThreshold - 2) {
            telemetry.report(distinct(index))
        }
        overflowing.loseOneOnNextPrune()
        telemetry.report(distinct(TelemetryLimits.flushThreshold))
        dispatcher.runDelayed()

        let noticeIds = exporter.batches.flatMap(\.records).filter { $0.eventName == "paydock.telemetry.dropped" }.map(\.id)
        XCTAssertEqual(exporter.batches.count, 2)
        XCTAssertEqual(noticeIds.count, 2)
        XCTAssertEqual(Set(noticeIds).count, 2, "a sent notice was sent again: \(noticeIds)")
        XCTAssertTrue(telemetry.currentState().notices.isEmpty)
    }

    // MARK: - Network failures (R_01, R_09)

    /// Start sets one observer, which keeps the earlier one and forwards to it; a failed observed attempt is stored as
    /// a network failure.
    func testStart_SetsOneObserver_KeepingThePrevious_AndAFailedAttemptIsStoredAsANetworkFailure() throws {
        let previous = RecordingRequestObserver()
        let slot = FakeRequestObserverSlot(previous)
        let telemetry = makeTelemetry(requestObservers: slot)
        XCTAssertEqual(slot.setCount, 0, "an observer was set before start")

        telemetry.start()

        XCTAssertEqual(slot.setCount, 1)
        let observer = try XCTUnwrap(slot.current)
        XCTAssertFalse(observer === previous)
        observer.requestDidFinish(NetworkObservations.observation(method: .get, path: "/v1/gateways/63f0c1d2/wallet-config",
                                                                  statusCode: 503))
        XCTAssertEqual(previous.observations.count, 1)
        XCTAssertEqual(store.saved.count, 1)
        let record = try XCTUnwrap(store.saved.first)
        XCTAssertEqual(record.eventName, "paydock.network.failure")
        XCTAssertEqual(record.value("url.template"), .string("/v1/gateways/{id}/wallet-config"))
        XCTAssertEqual(record.value("paydock.group.key"), .string("http GET /v1/gateways/{id}/wallet-config 503"))
    }

    /// The telemetry endpoint's host is excluded, a success gives nothing, and both still reach the earlier observer.
    func testTheObserver_ExcludesTheTelemetryHost_AndIgnoresSuccesses() throws {
        let previous = RecordingRequestObserver()
        let slot = FakeRequestObserverSlot(previous)
        let telemetry = ActiveTelemetry(endpoint: "https://api-sandbox.paydock.com/v1/logs", deviceContextProvider: provider,
                                        clock: clock,
                                        monotonic: FixedMonotonicClock(), idGenerator: FixedIdGenerator(id: Self.sessionId),
                                        dispatcher: dispatcher,
                                        ports: ActiveTelemetry.Ports(store: store, requestObservers: slot))
        telemetry.start()
        let observer = try XCTUnwrap(slot.current)

        observer.requestDidFinish(NetworkObservations.observation(path: "/v1/logs", statusCode: 500))
        observer.requestDidFinish(NetworkObservations.observation(statusCode: 200))

        XCTAssertEqual(store.saved, [])
        XCTAssertEqual(previous.observations.count, 2)
    }

    func testASecondStart_SetsNothing() {
        let slot = FakeRequestObserverSlot()
        let telemetry = makeTelemetry(requestObservers: slot)

        telemetry.start()
        let first = slot.current
        telemetry.start()

        XCTAssertEqual(slot.setCount, 1)
        XCTAssertTrue(slot.current === first)
    }

    func testWithoutASlot_StartRegistersNothing() {
        let before = NetworkingLib.shared.requestObserver

        makeTelemetry().start()

        XCTAssertTrue(NetworkingLib.shared.requestObserver === before)
    }

    // MARK: - Helpers

    /// A recording store whose next prune reports one record lost to the cap when asked, as a full store does when a
    /// new record pushes the oldest out.
    private final class OverflowingStore: DurableStore, @unchecked Sendable {
        private let inner = RecordingDurableStore()
        private let lock = NSLock()
        private var owed = 0

        func loseOneOnNextPrune() {
            lock.lock()
            owed = 1
            lock.unlock()
        }

        func save(_ record: TelemetryRecord) { inner.save(record) }
        func saveCrash(_ record: TelemetryRecord, timeout: TimeInterval) -> Bool {
            inner.saveCrash(record, timeout: timeout)
        }
        func oldest(max: Int) -> [TelemetryRecord] { inner.oldest(max: max) }
        func remove(ids: [String]) { inner.remove(ids: ids) }
        func count() -> Int { inner.count() }

        func prune(now: Int64) -> PruneResult {
            _ = inner.prune(now: now)
            lock.lock()
            defer { lock.unlock() }
            let storeFull = owed
            owed = 0
            return PruneResult(storeFull: storeFull)
        }
    }

    private func makeTelemetry(
        store: (any DurableStore)? = nil,
        exporter: any Exporter = ScriptedExporter(),
        dispatcher: (any TelemetryDispatcher)? = nil,
        clockOffset: ClockOffset? = nil,
        requestObservers: (any RequestObserverSlot)? = nil
    ) -> ActiveTelemetry {
        ActiveTelemetry(
            endpoint: TelemetryFixtures.endpoint,
            deviceContextProvider: provider,
            clock: clock,
            monotonic: FixedMonotonicClock(),
            idGenerator: FixedIdGenerator(id: Self.sessionId),
            dispatcher: dispatcher ?? self.dispatcher,
            ports: ActiveTelemetry.Ports(
                store: store ?? self.store,
                exporter: exporter,
                lifecycle: lifecycle,
                connection: connection,
                clockOffset: clockOffset ?? ClockOffset(clock: clock),
                retryPolicy: RetryPolicy(random: FixedRandom().function),
                requestObservers: requestObservers
            )
        )
    }

    /// An event of its own exception type, so the duplicate gate never merges it with another.
    private func distinct(_ index: Int) -> TelemetryEvent {
        TelemetryFixtures.crash("Sample.Crash\(index)")
    }

    /// A stored record from a run of the given session, of its own exception type.
    private func stored(_ sequence: Int, sessionId: String, at time: Int64) -> TelemetryRecord {
        Allowlist.filter(RecordFactory.create(
            PendingRecord(id: "\(sessionId)-\(sequence)", sessionId: sessionId, event: distinct(sequence), createdAt: time),
            connection: .wifi
        ))
    }

    /// Waits until every task posted to the queue so far has run.
    private func drain(_ serial: SerialTelemetryDispatcher) {
        let done = expectation(description: "the queue drained")
        serial.post { done.fulfill() }
        wait(for: [done], timeout: 5)
    }

    private func waitUntil(timeout: TimeInterval = 5, _ condition: () -> Bool) {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.01)
        }
        XCTAssertTrue(condition(), "the condition did not hold within \(timeout) s")
    }
}
