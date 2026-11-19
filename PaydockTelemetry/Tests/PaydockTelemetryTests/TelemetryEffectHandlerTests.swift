//
//  TelemetryEffectHandlerTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

final class TelemetryEffectHandlerTests: XCTestCase {

    private final class DelayLog: @unchecked Sendable {
        private let lock = NSLock()
        private var items: [Int64] = []

        var values: [Int64] {
            lock.lock()
            defer { lock.unlock() }
            return items
        }

        func append(_ value: Int64) {
            lock.lock()
            items.append(value)
            lock.unlock()
        }
    }

    private static let sessionId = "0b6f2c4e-93a1-4d7e-8f25-6c1d9e3a7b40"
    private static let now: Int64 = 1_793_852_047_512

    private let store = RecordingDurableStore()
    private let delays = DelayLog()
    private let connection = RecordingConnectionMonitor(.wifi)
    private let clock = FixedClock(TelemetryEffectHandlerTests.now)
    private let record = PendingRecord(id: "\(sessionId)-1", sessionId: sessionId, event: TelemetryFixtures.crash(),
                                       createdAt: TelemetryEffectHandlerTests.now - 1_000)

    // MARK: - persist

    func testPersist_SavesTheBuiltAndFilteredRecord_WithTheMonitorsConnectionType() throws {
        let followUps = makeHandler().run([.persist(record)])

        let saved = try XCTUnwrap(store.saved.first)
        XCTAssertEqual(store.saved, [Allowlist.filter(RecordFactory.create(record, connection: .wifi))])
        XCTAssertEqual(saved.id, record.id)
        XCTAssertEqual(saved.value("log.record.uid"), .string(record.id))
        XCTAssertEqual(saved.value("network.connection.type"), .string("wifi"))
        XCTAssertEqual(saved.sessionId, Self.sessionId)
        XCTAssertEqual(saved.timeUnixMillis, record.createdAt)
        XCTAssertEqual(followUps, [])
    }

    func testPersist_PrunesAfterTheSave_WithTheClocksTime() {
        _ = makeHandler().run([.persist(record)])

        XCTAssertEqual(store.pruneTimes, [Self.now])
        XCTAssertEqual(store.count(), 1)
    }

    func testPersist_PruneCounts_FollowAsDrops_StoreFullThenTooOld() {
        store.pruneResult = PruneResult(tooOld: 2, storeFull: 3)

        let followUps = makeHandler().run([.persist(record)])

        XCTAssertEqual(followUps, [.recordsDropped(reason: .storeFull, count: 3), .recordsDropped(reason: .tooOld, count: 2)])
    }

    func testPersist_ARecordWithoutSessionId_IsNotSaved_AndCountsOneRejected() {
        let incomplete = PendingRecord(id: "", sessionId: "", event: TelemetryFixtures.crash(), createdAt: Self.now)

        let followUps = makeHandler().run([.persist(incomplete)])

        XCTAssertEqual(store.saved, [])
        XCTAssertEqual(store.pruneTimes, [])
        XCTAssertEqual(followUps, [.recordsDropped(reason: .rejected, count: 1)])
    }

    func testPersist_ADroppedNoticeWithoutSessionId_IsNotSaved_AndCountsNothing_SoItCannotLoop() {
        let notice = PendingRecord(id: "", sessionId: "", event: .dropped(reason: .rejected, count: 1), createdAt: Self.now)

        let followUps = makeHandler().run([.persist(notice)])

        XCTAssertEqual(store.saved, [])
        XCTAssertEqual(followUps, [])
    }

    // MARK: - export

    func testExport_FlushesWithTheClocksTime_AndCountsPending() {
        save(1, 2)
        let exporter = ScriptedExporter()

        let followUps = makeHandler(exporter).run([.export(maxRecords: 1)])

        XCTAssertEqual(exporter.batchIds, [["\(Self.sessionId)-1"], ["\(Self.sessionId)-2"]])
        XCTAssertEqual(store.pruneTimes, [Self.now])
        XCTAssertEqual(store.count(), 0)
        XCTAssertEqual(followUps, [.pendingCounted(0)])
    }

    func testExport_Stopped_FollowsWithExportStopped_ThenPendingCounted() {
        save(1, 2)

        let followUps = makeHandler(ScriptedExporter([.unauthorized])).run([.export(maxRecords: 50)])

        XCTAssertEqual(followUps, [.exportStopped, .pendingCounted(2)])
    }

    func testExport_SentNotices_FollowAsNoticesExported() {
        save(1)
        store.save(RecordFactory.create(
            PendingRecord(id: "\(Self.sessionId)-2", sessionId: Self.sessionId, event: .dropped(reason: .rateLimit, count: 4),
                          createdAt: Self.now),
            connection: .unknown
        ))

        let followUps = makeHandler(ScriptedExporter()).run([.export(maxRecords: 50)])

        XCTAssertEqual(followUps, [.noticesExported(["\(Self.sessionId)-2"]), .pendingCounted(0)])
    }

    func testExport_Counts_FollowAsDrops_TooOldThenStoreFullThenRejected() {
        save(1, 2)
        store.pruneResult = PruneResult(tooOld: 1, storeFull: 4)

        let followUps = makeHandler(ScriptedExporter([.rejected])).run([.export(maxRecords: 50)])

        XCTAssertEqual(followUps, [
            .pendingCounted(0),
            .recordsDropped(reason: .tooOld, count: 1),
            .recordsDropped(reason: .storeFull, count: 4),
            .recordsDropped(reason: .rejected, count: 2)
        ])
    }

    // MARK: - scheduleFlush and drop

    func testScheduleFlush_CallsTheClosure_WithNoFollowUp() {
        let followUps = makeHandler().run([.scheduleFlush(delayMilliseconds: 10_000)])

        XCTAssertEqual(delays.values, [10_000])
        XCTAssertEqual(followUps, [])
    }

    func testDrop_DoesNothing() {
        let followUps = makeHandler().run([.drop(.disabled), .drop(.rateLimit), .drop(.notReportable),
                                           .drop(.alreadyOpened)])

        XCTAssertEqual(store.saved, [])
        XCTAssertEqual(store.pruneTimes, [])
        XCTAssertEqual(delays.values, [])
        XCTAssertEqual(followUps, [])
    }

    // MARK: - order

    /// Each effect runs on its own: a rejected record does not stop the next effect, and the follow-ups keep the
    /// effects' order.
    func testEffects_RunInOrder_EachOnItsOwn_AndTheFollowUpsKeepTheirOrder() {
        let incomplete = PendingRecord(id: "", sessionId: "", event: TelemetryFixtures.crash(), createdAt: Self.now)
        let second = PendingRecord(id: "\(Self.sessionId)-2", sessionId: Self.sessionId, event: TelemetryFixtures.sdkError(),
                                   createdAt: Self.now)
        let exporter = ScriptedExporter()

        let followUps = makeHandler(exporter).run([
            .persist(record), .persist(incomplete), .scheduleFlush(delayMilliseconds: 5), .persist(second),
            .export(maxRecords: 50), .scheduleFlush(delayMilliseconds: 6)
        ])

        XCTAssertEqual(store.saved.map(\.id), [record.id, second.id])
        XCTAssertEqual(exporter.batchIds, [[record.id, second.id]])
        XCTAssertEqual(delays.values, [5, 6])
        XCTAssertEqual(followUps, [.recordsDropped(reason: .rejected, count: 1), .pendingCounted(0)])
    }

    /// R_09: a notice the export just sent follows first, before a drop an earlier effect of the same run counted, so
    /// the reducer clears it before the drop and the drop starts a new notice instead of updating the sent one.
    func testSentNotices_FollowFirst_BeforeTheDropsOfAnEarlierEffect() {
        let noticeId = "\(Self.sessionId)-2"
        store.save(RecordFactory.create(
            PendingRecord(id: noticeId, sessionId: Self.sessionId, event: .dropped(reason: .storeFull, count: 1),
                          createdAt: Self.now),
            connection: .unknown
        ))
        store.pruneResult = PruneResult(storeFull: 1)

        let followUps = makeHandler().run([.persist(record), .export(maxRecords: 50)])

        XCTAssertEqual(followUps, [
            .noticesExported([noticeId]),
            .recordsDropped(reason: .storeFull, count: 1),
            .pendingCounted(0),
            .recordsDropped(reason: .storeFull, count: 1)
        ])
    }

    func testNoOpPorts() {
        let built = RecordFactory.create(record, connection: .wifi)
        NoOpDurableStore().save(built)

        XCTAssertEqual(NoOpDurableStore().oldest(max: 50), [])
        XCTAssertEqual(NoOpDurableStore().count(), 0)
        XCTAssertEqual(NoOpDurableStore().prune(now: 1), PruneResult())
        NoOpDurableStore().remove(ids: [built.id])
        XCTAssertEqual(NoOpExporter().export(ExportBatch(resource: FakeDeviceContextProvider.attributes, records: [built])),
                       .success(rejectedRecords: 0))
        let monitor = NoOpConnectionMonitor()
        monitor.start()
        XCTAssertEqual(monitor.current(), .unknown)
        let called = DelayLog()
        NoOpAppLifecycle().register { finished in
            called.append(1)
            finished()
        }
        XCTAssertEqual(called.values, [])
    }

    func testResourceAttributes_AsMap_HoldsTheFourteenKeys() {
        let map = FakeDeviceContextProvider.attributes.asMap()

        XCTAssertEqual(map, [
            "service.name": .string("paydock-mobile-sdk"),
            "service.namespace": .string("paydock"),
            "service.version": .string("0.0.0-test"),
            "paydock.sdk.platform": .string("ios"),
            "paydock.telemetry.spec_version": .int(1),
            "deployment.environment.name": .string("sandbox"),
            "os.name": .string("iOS"),
            "os.version": .string("17.0"),
            "device.manufacturer": .string("Apple"),
            "device.model.identifier": .string("iPhone15,2"),
            "app.installation.id": .string(FakeDeviceContextProvider.installationId),
            "paydock.app.id": .string("com.paydock.sample"),
            "paydock.app.version": .string("1.0.0"),
            "paydock.app.debuggable": .bool(true)
        ])
        XCTAssertEqual(map.count, 14)
    }

    // MARK: - Helpers

    private func makeHandler(_ exporter: any Exporter = ScriptedExporter()) -> TelemetryEffectHandler {
        let runner = ExportRunner(store: store, exporter: exporter, deviceContext: FakeDeviceContextProvider(),
                                  clockOffset: ClockOffset(clock: clock), monotonic: FixedMonotonicClock(),
                                  retryPolicy: RetryPolicy(random: FixedRandom().function), scheduleRetry: { _ in })
        return TelemetryEffectHandler(store: store, runner: runner, deviceContext: FakeDeviceContextProvider(),
                                      connection: connection, clock: clock,
                                      scheduleFlush: { [delays] delay in delays.append(delay) })
    }

    /// Saves one stored record per sequence, oldest first, each of its own exception type so none merge.
    private func save(_ sequences: Int...) {
        for sequence in sequences {
            let pending = PendingRecord(id: "\(Self.sessionId)-\(sequence)", sessionId: Self.sessionId,
                                        event: TelemetryFixtures.crash("Sample.Crash\(sequence)"),
                                        createdAt: Self.now - 10_000 + Int64(sequence))
            store.save(Allowlist.filter(RecordFactory.create(pending, connection: .wifi)))
        }
    }
}
