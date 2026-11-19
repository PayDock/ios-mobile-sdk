//
//  ExportRunnerTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// R_11–R_13: gating, batching, stamping, the batch check and the retry rules of the flush runner.
final class ExportRunnerTests: XCTestCase {

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

    private struct StubDeviceContext: DeviceContextProvider {
        let installationId: String

        func current() -> ResourceAttributes {
            let base = FakeDeviceContextProvider.attributes
            return ResourceAttributes(
                serviceVersion: base.serviceVersion, deploymentEnvironmentName: base.deploymentEnvironmentName,
                osVersion: base.osVersion, deviceModelIdentifier: base.deviceModelIdentifier,
                appInstallationId: installationId, appId: base.appId, appVersion: base.appVersion,
                appDebuggable: base.appDebuggable
            )
        }
    }

    private static let session = "0b6f2c4e-93a1-4d7e-8f25-6c1d9e3a7b40"
    private static let now: Int64 = 1_793_852_047_512
    private static let twoHours: Int64 = 7_200_000

    private let store = RecordingDurableStore()
    private let monotonic = FixedMonotonicClock(1_000)
    private let clock = FixedClock(ExportRunnerTests.now)
    private lazy var offset = ClockOffset(clock: clock)
    private let retries = DelayLog()

    // MARK: - Sending and batching

    func testFlush_SendsStoredRecords_OldestFirst_AndRemovesThemOnSuccess() {
        save(record(3, at: Self.now - 10), record(1, at: Self.now - 30), record(2, at: Self.now - 20))
        let exporter = ScriptedExporter()

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(exporter.batchIds, [[id(1), id(2), id(3)]])
        XCTAssertEqual(exporter.batches.first?.resource, FakeDeviceContextProvider.attributes)
        XCTAssertEqual(store.count(), 0)
        XCTAssertEqual(report, FlushReport(pending: 0))
    }

    func testEmptyStore_SendsNothing() {
        let exporter = ScriptedExporter()

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        XCTAssertTrue(exporter.batches.isEmpty)
        XCTAssertEqual(report, FlushReport(pending: 0))
        XCTAssertTrue(retries.values.isEmpty)
    }

    func testPrune_RunsFirst_WithTheFlushTime_AndItsCountsAreReported() {
        save(record(1))
        store.pruneResult = PruneResult(tooOld: 2, storeFull: 3)

        let report = makeRunner(ScriptedExporter()).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(store.pruneTimes, [Self.now])
        XCTAssertEqual(report.tooOld, 2)
        XCTAssertEqual(report.storeFull, 3)
    }

    func testBatches_HoldAtMostMaxRecords() {
        save((1...7).map { record($0) })
        let exporter = ScriptedExporter()

        _ = makeRunner(exporter).flush(now: Self.now, maxRecords: 3)

        XCTAssertEqual(exporter.batchIds, [[id(1), id(2), id(3)], [id(4), id(5), id(6)], [id(7)]])
    }

    func testBatches_OfTheDefaultMaximum_Hold50Records() {
        save((1...60).map { record($0) })
        let exporter = ScriptedExporter()

        _ = makeRunner(exporter).flush(now: Self.now, maxRecords: TelemetryLimits.batchMaxRecords)

        XCTAssertEqual(exporter.batches.map(\.records.count), [50, 10])
    }

    func testBatches_HoldAtMostTheByteLimit() {
        save((1...5).map { large(record($0), bytes: 100_000) })
        let exporter = ScriptedExporter()

        _ = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(exporter.batchIds, [[id(1), id(2)], [id(3), id(4)], [id(5)]])
        for batch in exporter.batches {
            XCTAssertLessThanOrEqual(OtlpLogEncoder.encode(resource: batch.resource, records: batch.records).count,
                                     TelemetryLimits.batchMaxBytes)
        }
    }

    func testASingleLargerRecord_GoesAlone() {
        save(record(1, at: Self.now - 3), large(record(2, at: Self.now - 2), bytes: 300_000), record(3, at: Self.now - 1))
        let exporter = ScriptedExporter()

        _ = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(exporter.batchIds, [[id(1)], [id(2)], [id(3)]])
        XCTAssertEqual(store.count(), 0)
    }

    func testFlush_ReadsAtMostTheStoreMaximum() {
        save((1...105).map { record($0) })
        let exporter = ScriptedExporter()

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(exporter.batches.map(\.records.count), [50, 50])
        XCTAssertEqual(report.pending, 5)
    }

    // MARK: - Gating and the batch check (R_13)

    func testMissingInstallationId_SendsNothing_AndKeepsTheRecords() {
        save(record(1))
        let exporter = ScriptedExporter()

        let report = makeRunner(exporter, deviceContext: StubDeviceContext(installationId: "")).flush(now: Self.now, maxRecords: 50)

        XCTAssertTrue(exporter.batches.isEmpty)
        XCTAssertEqual(report, FlushReport(pending: 1))
    }

    func testMalformedInstallationId_SendsNothing() {
        save(record(1))
        let exporter = ScriptedExporter()

        _ = makeRunner(exporter, deviceContext: StubDeviceContext(installationId: "not-a-uuid")).flush(now: Self.now, maxRecords: 50)

        XCTAssertTrue(exporter.batches.isEmpty)
        XCTAssertEqual(store.count(), 1)
    }

    func testRecordWithoutSessionId_IsRemoved_AndCountedRejected() {
        let complete = record(1)
        let attributes = record(2).attributes.filter { $0.key != "session.id" }
        let incomplete = TelemetryRecord(id: id(2), timeUnixMillis: Self.now, severity: complete.severity,
                                         body: RecordBody.of(attributes), attributes: attributes)
        save(complete, incomplete)
        let exporter = ScriptedExporter()

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(exporter.batchIds, [[id(1)]])
        XCTAssertEqual(report.rejected, 1)
        XCTAssertEqual(store.count(), 0)
    }

    func testBatchCheck_RecordWhoseBodyChangedAfterFiltering_IsRemoved_AndCountedRejected() {
        let filtered = record(2)
        let changed = TelemetryRecord(id: filtered.id, timeUnixMillis: filtered.timeUnixMillis, severity: filtered.severity,
                                      body: filtered.body + " · changed", attributes: filtered.attributes)
        save(record(1), changed, record(3))
        let exporter = ScriptedExporter()

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(exporter.batchIds, [[id(1), id(3)]])
        XCTAssertEqual(report.rejected, 1)
        XCTAssertEqual(store.count(), 0)
    }

    func testBatchCheck_RecordWithASensitiveValue_IsRemoved_AndCountedRejected() {
        let sensitive = record(2).with("paydock.widget", .string("someone@example.com"))
        save(record(1), sensitive)
        let exporter = ScriptedExporter()

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(exporter.batchIds, [[id(1)]])
        XCTAssertEqual(report.rejected, 1)
        XCTAssertEqual(store.count(), 0)
    }

    func testEverySentBatch_PassesTheBatchCheck() {
        save(record(1), notice(2), record(3))
        let exporter = ScriptedExporter()

        _ = makeRunner(exporter).flush(now: Self.now, maxRecords: 2)

        XCTAssertEqual(exporter.batches.count, 2)
        for batch in exporter.batches {
            XCTAssertEqual(Allowlist.violations(resource: batch.resource, records: batch.records), [])
        }
    }

    // MARK: - Duplicates

    func testDuplicates_AreMergedBeforeSending_AndEverySourceRemoved() {
        let event = TelemetryFixtures.sdkError("Sample.Same")
        save(record(1, event, at: Self.now - 30), record(2, at: Self.now - 20), record(3, event, at: Self.now - 10))
        let exporter = ScriptedExporter()

        _ = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(exporter.batchIds, [[id(1), id(2)]])
        XCTAssertEqual(exporter.batches.first?.records.first?.value("paydock.occurrences"), .int(2))
        XCTAssertEqual(store.count(), 0)
    }

    // MARK: - Results (R_12)

    func testPartialSuccess_CountsTheRejectedRecords() {
        save((1...4).map { record($0) })

        let report = makeRunner(ScriptedExporter([.success(rejectedRecords: 3)])).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(report.rejected, 3)
        XCTAssertEqual(store.count(), 0)
    }

    func testPartialSuccess_IsCappedAtTheBatchSources() {
        save((1...4).map { record($0) })

        let report = makeRunner(ScriptedExporter([.success(rejectedRecords: 99), .success(rejectedRecords: 99)]))
            .flush(now: Self.now, maxRecords: 3)

        XCTAssertEqual(report.rejected, 4)
    }

    func testTooLarge_SplitsTheBatchInHalf_AndSendsBothHalves() {
        save((1...5).map { record($0) })
        let exporter = ScriptedExporter([.tooLarge])

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(exporter.batchIds, [[id(1), id(2), id(3), id(4), id(5)], [id(1), id(2)], [id(3), id(4), id(5)]])
        XCTAssertEqual(report.rejected, 0)
        XCTAssertEqual(store.count(), 0)
    }

    func testTooLarge_OnASingleRecord_RemovesIt_AndCountsItRejected() {
        save(record(1), record(2))
        let exporter = ScriptedExporter([.tooLarge, .tooLarge])

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(exporter.batchIds, [[id(1), id(2)], [id(1)], [id(2)]])
        XCTAssertEqual(report.rejected, 1)
        XCTAssertEqual(store.count(), 0)
    }

    func testRejected_RemovesTheBatch_CountsIt_AndGoesOnToTheNextBatch() {
        save((1...3).map { record($0) })
        let exporter = ScriptedExporter([.rejected])

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 2)

        XCTAssertEqual(exporter.batchIds, [[id(1), id(2)], [id(3)]])
        XCTAssertEqual(report.rejected, 2)
        XCTAssertEqual(store.count(), 0)
    }

    /// D22: a batch the collector rejects (`400`) is removed and counted rejected, and no retry is scheduled.
    func testRejectedBatch_IsRemoved_CountedRejected_AndNotRetried() {
        save((1...2).map { record($0) })
        let exporter = ScriptedExporter([.rejected])

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(exporter.batchIds, [[id(1), id(2)]])
        XCTAssertEqual(report.rejected, 2)
        XCTAssertFalse(report.stopped)
        XCTAssertEqual(store.count(), 0)
        XCTAssertTrue(retries.values.isEmpty)
    }

    func testUnauthorized_StopsForTheProcess_AndKeepsTheFiles() {
        save((1...3).map { record($0) })
        let exporter = ScriptedExporter([.unauthorized])

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 2)

        XCTAssertEqual(exporter.batchIds, [[id(1), id(2)]])
        XCTAssertEqual(report, FlushReport(pending: 3, stopped: true))
        XCTAssertTrue(retries.values.isEmpty)
    }

    func testAfterUnauthorized_ALaterFlushSendsNothing() {
        save(record(1))
        let exporter = ScriptedExporter([.unauthorized])
        let runner = makeRunner(exporter)
        _ = runner.flush(now: Self.now, maxRecords: 50)
        monotonic.advance(by: TelemetryLimits.hourMilliseconds)

        let report = runner.flush(now: Self.now + 60_000, maxRecords: 50)

        XCTAssertEqual(exporter.batches.count, 1)
        XCTAssertEqual(store.pruneTimes, [Self.now])
        XCTAssertEqual(report, FlushReport(pending: 1))
    }

    func testRetry_KeepsTheFiles_SchedulesARetry_AndEndsTheFlush() {
        save((1...3).map { record($0) })
        let exporter = ScriptedExporter([.retry(retryAfterMilliseconds: nil)])

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 2)

        XCTAssertEqual(exporter.batchIds, [[id(1), id(2)]])
        XCTAssertEqual(retries.values, [2_500])
        XCTAssertEqual(report, FlushReport(pending: 3))
    }

    func testRetry_HonoursRetryAfter() {
        save(record(1))

        _ = makeRunner(ScriptedExporter([.retry(retryAfterMilliseconds: 7_000)])).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(retries.values, [7_000])
    }

    /// The largest `Retry-After` the transport passes on schedules the retry an hour out, without overflowing.
    func testRetry_AHugeRetryAfter_WaitsAnHour() {
        save(record(1))

        _ = makeRunner(ScriptedExporter([.retry(retryAfterMilliseconds: Int64.max / 1_000 * 1_000)]))
            .flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(retries.values, [TelemetryLimits.retryAfterMaxMilliseconds])
    }

    func testBeforeTheNextAttemptTime_SendsNothing() {
        save(record(1))
        let exporter = ScriptedExporter([.retry(retryAfterMilliseconds: nil)])
        let runner = makeRunner(exporter)
        _ = runner.flush(now: Self.now, maxRecords: 50)
        monotonic.advance(by: 2_499)

        let report = runner.flush(now: Self.now + 2_499, maxRecords: 50)

        XCTAssertEqual(exporter.batches.count, 1)
        XCTAssertEqual(store.pruneTimes, [Self.now])
        XCTAssertEqual(report, FlushReport(pending: 1))
    }

    func testAtTheNextAttemptTime_SendsAgain() {
        save(record(1))
        let exporter = ScriptedExporter([.retry(retryAfterMilliseconds: nil)])
        let runner = makeRunner(exporter)
        _ = runner.flush(now: Self.now, maxRecords: 50)
        monotonic.advance(by: 2_500)

        let report = runner.flush(now: Self.now + 2_500, maxRecords: 50)

        XCTAssertEqual(exporter.batches.count, 2)
        XCTAssertEqual(report, FlushReport(pending: 0))
    }

    func testNextAttemptTime_FollowsTheMonotonicClock_NotTheWallClock() {
        save(record(1))
        let exporter = ScriptedExporter([.retry(retryAfterMilliseconds: nil)])
        let runner = makeRunner(exporter)
        _ = runner.flush(now: Self.now, maxRecords: 50)

        _ = runner.flush(now: Self.now + TelemetryLimits.hourMilliseconds, maxRecords: 50)

        XCTAssertEqual(exporter.batches.count, 1)
    }

    func testFiveFailedAttempts_StopForTheProcess() {
        save(record(1))
        let exporter = ScriptedExporter(fallback: .retry(retryAfterMilliseconds: nil))
        let runner = makeRunner(exporter)

        let reports = (1...6).map { _ in
            let report = runner.flush(now: Self.now, maxRecords: 50)
            monotonic.advance(by: TelemetryLimits.retryMaxDelayMilliseconds)
            return report
        }

        XCTAssertEqual(exporter.batches.count, TelemetryLimits.retryMaxAttempts)
        XCTAssertEqual(reports.map(\.stopped), [false, false, false, false, true, false])
        XCTAssertEqual(retries.values.count, 4)
        XCTAssertEqual(store.count(), 1)
    }

    func testBackOff_GrowsWithEachFailedAttempt() {
        save(record(1))
        let runner = makeRunner(ScriptedExporter(fallback: .retry(retryAfterMilliseconds: nil)))

        for _ in 1...4 {
            _ = runner.flush(now: Self.now, maxRecords: 50)
            monotonic.advance(by: TelemetryLimits.retryMaxDelayMilliseconds)
        }

        XCTAssertEqual(retries.values, [2_500, 5_000, 10_000, 20_000])
    }

    func testSuccess_ResetsTheFailedAttempts() {
        let retry = ExportResult.retry(retryAfterMilliseconds: nil)
        let exporter = ScriptedExporter([retry, retry, retry, .success(rejectedRecords: 0), retry, retry, retry, retry])
        let runner = makeRunner(exporter)
        var stopped: [Bool] = []

        for sequence in 1...5 {
            save(record(sequence))
            stopped.append(runner.flush(now: Self.now, maxRecords: 50).stopped)
            monotonic.advance(by: TelemetryLimits.retryMaxDelayMilliseconds)
        }
        stopped += (1...3).map { _ in
            let report = runner.flush(now: Self.now, maxRecords: 50)
            monotonic.advance(by: TelemetryLimits.retryMaxDelayMilliseconds)
            return report.stopped
        }

        XCTAssertEqual(exporter.batches.count, 8)
        XCTAssertEqual(stopped, Array(repeating: false, count: 8))
        XCTAssertEqual(retries.values, [2_500, 5_000, 10_000, 2_500, 5_000, 10_000, 20_000])
    }

    // MARK: - Notices

    func testNoticesOfAnAcceptedBatch_AreReportedExported() {
        save(record(1), notice(2))

        let report = makeRunner(ScriptedExporter()).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(report.exportedNoticeIds, [id(2)])
    }

    func testNoticesOfARejectedBatch_AreReportedExported() {
        save(notice(1), record(2), notice(3))

        let report = makeRunner(ScriptedExporter([.rejected, .success(rejectedRecords: 0)])).flush(now: Self.now, maxRecords: 2)

        XCTAssertEqual(report.exportedNoticeIds, [id(1), id(3)])
        XCTAssertEqual(report.rejected, 1, "only record 2 counts; a lost notice is never counted as rejected")
    }

    func testARejectedBatchOfNoticesOnly_IsRemoved_AndCountsNothing() {
        save(notice(1), notice(2))

        let report = makeRunner(ScriptedExporter([.rejected])).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(report.rejected, 0)
        XCTAssertEqual(report.exportedNoticeIds, [id(1), id(2)])
        XCTAssertEqual(store.count(), 0)
    }

    func testPartialSuccess_CountsAtMostTheBatchsRecords_NoticesExcluded() {
        save(record(1), notice(2), notice(3))

        let report = makeRunner(ScriptedExporter([.success(rejectedRecords: 3)])).flush(now: Self.now, maxRecords: 50)

        XCTAssertEqual(report.rejected, 1)
        XCTAssertEqual(store.count(), 0)
    }

    func testNoticesOfARetriedOrUnauthorizedBatch_AreNotReportedExported() {
        save(notice(1))
        XCTAssertEqual(makeRunner(ScriptedExporter([.retry(retryAfterMilliseconds: nil)]))
            .flush(now: Self.now, maxRecords: 50).exportedNoticeIds, [])
        XCTAssertEqual(makeRunner(ScriptedExporter([.unauthorized])).flush(now: Self.now, maxRecords: 50).exportedNoticeIds, [])
        XCTAssertEqual(store.count(), 1)
    }

    // MARK: - Stamping at send (D20)

    func testLateRecord_GoesOutWithTheSendTimeAndOccurredAt_ItsStoredRecordUnchanged() throws {
        let late = record(1, at: Self.now - Self.twoHours)
        save(late)
        let exporter = ScriptedExporter([.retry(retryAfterMilliseconds: nil)])

        _ = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        let sent = try XCTUnwrap(exporter.batches.first?.records.first)
        XCTAssertEqual(sent.timeUnixMillis, Self.now)
        XCTAssertEqual(sent.value(SendStamp.occurredAtKey), .string(UtcTimestamp.iso8601(Self.now - Self.twoHours)))
        XCTAssertEqual(sent.body, late.body)
        XCTAssertEqual(store.oldest(max: 10), [late])
    }

    func testOffset_CorrectsFreshAndLateRecords() throws {
        offset.measure(serverDateMilliseconds: Self.now + 5_000)
        save(record(1, at: Self.now - Self.twoHours), record(2, at: Self.now - 1_000))
        let exporter = ScriptedExporter()

        _ = makeRunner(exporter).flush(now: Self.now, maxRecords: 50)

        let sent = try XCTUnwrap(exporter.batches.first?.records)
        XCTAssertEqual(sent.map(\.timeUnixMillis), [Self.now + 5_000, Self.now + 4_000])
        XCTAssertEqual(sent[0].value(SendStamp.occurredAtKey), .string(UtcTimestamp.iso8601(Self.now - Self.twoHours + 5_000)))
        XCTAssertNil(sent[1].value(SendStamp.occurredAtKey))
    }

    func testEveryBatchOfOneFlush_CarriesTheFlushSendTime() {
        save((1...3).map { record($0, at: Self.now - Self.twoHours - Int64($0)) })
        let exporter = ScriptedExporter()

        _ = makeRunner(exporter).flush(now: Self.now, maxRecords: 1)

        XCTAssertEqual(exporter.batches.count, 3)
        XCTAssertEqual(exporter.batches.flatMap { $0.records.map(\.timeUnixMillis) }, [Self.now, Self.now, Self.now])
    }

    // MARK: - Pending

    func testPending_IsTheStoreCountAfterTheFlush() {
        save((1...3).map { record($0) })
        let exporter = ScriptedExporter([.success(rejectedRecords: 0), .retry(retryAfterMilliseconds: nil)])

        let report = makeRunner(exporter).flush(now: Self.now, maxRecords: 2)

        XCTAssertEqual(report.pending, 1)
        XCTAssertEqual(store.count(), 1)
    }

    // MARK: - Helpers

    private func makeRunner(_ exporter: ScriptedExporter,
                            deviceContext: any DeviceContextProvider = FakeDeviceContextProvider()) -> ExportRunner {
        ExportRunner(store: store, exporter: exporter, deviceContext: deviceContext, clockOffset: offset,
                     monotonic: monotonic, retryPolicy: RetryPolicy(random: FixedRandom(.lowest).function),
                     scheduleRetry: { [retries] delay in retries.append(delay) })
    }

    private func save(_ records: TelemetryRecord...) {
        save(records)
    }

    private func save(_ records: [TelemetryRecord]) {
        records.forEach(store.save)
    }

    private func id(_ sequence: Int) -> String {
        "\(Self.session)-\(sequence)"
    }

    /// A filtered record; by default each sequence gets its own error type, so no two merge.
    private func record(_ sequence: Int, _ event: TelemetryEvent? = nil, at time: Int64 = ExportRunnerTests.now) -> TelemetryRecord {
        let pending = PendingRecord(id: id(sequence), sessionId: Self.session,
                                    event: event ?? TelemetryFixtures.sdkError("Sample.Error\(sequence)"), createdAt: time)
        return Allowlist.filter(RecordFactory.create(pending, connection: .wifi))
    }

    private func notice(_ sequence: Int) -> TelemetryRecord {
        record(sequence, .dropped(reason: .rateLimit, count: 3))
    }

    /// The record with a stack trace that makes its JSON about `bytes` long; its body is unchanged.
    private func large(_ record: TelemetryRecord, bytes: Int) -> TelemetryRecord {
        let line = "\tat SampleModule.SampleType.sampleMethod()\n"
        let trace = String(repeating: line, count: bytes / line.utf8.count)
        return record.with("exception.stacktrace", .string(trace))
    }
}
