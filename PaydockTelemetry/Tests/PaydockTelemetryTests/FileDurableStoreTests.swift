//
//  FileDurableStoreTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation
import PaydockTelemetry
import XCTest

/// R_05, R_06: the disk is the queue. Every test runs in its own temporary directory, removed afterwards.
final class FileDurableStoreTests: XCTestCase {

    private final class CallCount: @unchecked Sendable {
        private let lock = NSLock()
        private var calls = 0

        var value: Int {
            lock.lock()
            defer { lock.unlock() }
            return calls
        }

        func increment() {
            lock.lock()
            calls += 1
            lock.unlock()
        }
    }

    private static let session = "0b6f2c4e-93a1-4d7e-8f25-6c1d9e3a7b40"
    private static let time: Int64 = 1_793_852_047_512

    private var temporary: TemporaryDirectory!
    private var folder: URL!

    override func setUpWithError() throws {
        temporary = try TemporaryDirectory()
        folder = temporary.child(FileDurableStore.directoryName)
    }

    override func tearDown() {
        temporary.remove()
    }

    // MARK: - Files

    func testOneFilePerRecord_AndUpsertById() {
        let store = makeStore()
        let first = record(1)
        let second = record(2)
        let updated = record(1, at: Self.time + 50)

        store.save(first)
        store.save(second)
        store.save(updated)

        XCTAssertEqual(fileNames(), ["\(first.id).json", "\(second.id).json"])
        XCTAssertEqual(store.count(), 2)
        XCTAssertEqual(store.oldest(max: 10), [second, updated])
    }

    func testAFileHoldsTheRecordJSON_AndNoTemporaryFileIsLeft() throws {
        let store = makeStore()
        let saved = record(1, TelemetryFixtures.networkFailure()).with("paydock.occurrences", .int(3))

        store.save(saved)
        store.save(saved)

        let data = try Data(contentsOf: folder.appendingPathComponent("\(saved.id).json"))
        XCTAssertEqual(data, OtlpLogEncoder.recordJSON(saved))
        XCTAssertEqual(OtlpLogEncoder.parseRecord(data), saved)
        XCTAssertEqual(fileNames().filter { $0.hasSuffix(".tmp") }, [])
    }

    func testOldest_IsByTime_AndAtMostMax() {
        let store = makeStore()
        let records = [record(1, at: Self.time + 30), record(2, at: Self.time + 10), record(3, at: Self.time + 20)]
        records.forEach(store.save)

        XCTAssertEqual(store.oldest(max: 2), [records[1], records[2]])
        XCTAssertEqual(store.oldest(max: 10), [records[1], records[2], records[0]])
        XCTAssertEqual(store.oldest(max: 0), [])
    }

    func testOldest_OrdersTheSequenceNumerically() {
        let store = makeStore()
        let records = [record(10), record(9), record(2)]
        records.forEach(store.save)

        XCTAssertEqual(store.oldest(max: 10).map(\.id), ["\(Self.session)-2", "\(Self.session)-9", "\(Self.session)-10"])
    }

    func testRemove_DeletesTheFiles() {
        let store = makeStore()
        let records = [record(1), record(2), record(3)]
        records.forEach(store.save)

        store.remove(ids: [records[0].id, records[2].id, "\(Self.session)-99"])

        XCTAssertEqual(fileNames(), ["\(records[1].id).json"])
        XCTAssertEqual(store.count(), 1)
        XCTAssertEqual(store.oldest(max: 10), [records[1]])
    }

    /// A record survives process death: a new instance on the same folder reads every record.
    func testANewInstanceOnTheSameFolder_ReadsEveryRecord() {
        let records = [record(1), record(2, .dropped(reason: .rejected, count: 2)), record(3, TelemetryFixtures.crash())]
        let first = makeStore()
        records.forEach(first.save)

        let second = makeStore()

        XCTAssertEqual(second.count(), 3)
        XCTAssertEqual(second.oldest(max: 10), records)
    }

    // MARK: - Prune

    func testPrune_KeepsAtMost100Records_RemovingTheOldest() {
        let store = makeStore()
        let records = (1...105).map { record($0, .widgetOpened(widget: "Widget\($0)"), at: Self.time + Int64($0)) }
        records.forEach(store.save)

        XCTAssertEqual(store.prune(now: Self.time + 1_000), PruneResult(tooOld: 0, storeFull: 5))

        XCTAssertEqual(store.count(), 100)
        XCTAssertEqual(store.oldest(max: 200), Array(records.dropFirst(5)))
    }

    func testPrune_KeepsAtMost1MB() throws {
        let store = makeStore()
        let padding = String(repeating: "a", count: 100_000)
        let records = (1...12).map { index in
            record(index, .sdkError(error: TelemetryFixtures.info(), errorCode: "CODE_\(index)"), at: Self.time + Int64(index))
                .with("exception.stacktrace", .string(padding))
        }
        records.forEach(store.save)

        XCTAssertEqual(store.prune(now: Self.time + 1_000), PruneResult(tooOld: 0, storeFull: 2))

        let bytes = try fileNames().reduce(0) { $0 + (try Data(contentsOf: folder.appendingPathComponent($1))).count }
        XCTAssertLessThanOrEqual(bytes, TelemetryLimits.storeMaxBytes)
        XCTAssertEqual(store.oldest(max: 200), Array(records.dropFirst(2)))
    }

    func testPrune_RemovesRecordsOlderThan156h_ByRecordTime() {
        let store = makeStore()
        let now = Self.time + 2 * TelemetryLimits.recordMaxAgeMilliseconds
        let tooOld = record(1, at: now - TelemetryLimits.recordMaxAgeMilliseconds - 1)
        let oldNotice = record(2, .dropped(reason: .storeFull, count: 1), at: now - TelemetryLimits.recordMaxAgeMilliseconds - 5)
        let atTheLimit = record(3, TelemetryFixtures.crash(), at: now - TelemetryLimits.recordMaxAgeMilliseconds)
        let fresh = record(4, TelemetryFixtures.networkFailure(), at: now)
        [tooOld, oldNotice, atTheLimit, fresh].forEach(store.save)

        XCTAssertEqual(store.prune(now: now), PruneResult(tooOld: 1, storeFull: 0))

        XCTAssertEqual(store.oldest(max: 10), [atTheLimit, fresh])
    }

    func testPrune_RemovesNoticesForSpace_OnlyAfterEveryOtherRecord() {
        let store = makeStore()
        let notice = record(1, .dropped(reason: .rateLimit, count: 4), at: Self.time)
        let others = (2...102).map { record($0, .widgetOpened(widget: "Widget\($0)"), at: Self.time + Int64($0)) }
        store.save(notice)
        others.forEach(store.save)

        XCTAssertEqual(store.prune(now: Self.time + 1_000), PruneResult(tooOld: 0, storeFull: 2))

        XCTAssertEqual(store.oldest(max: 200), [notice] + others.dropFirst(2))
    }

    func testPrune_WithOnlyNoticesLeft_RemovesTheOldestUncounted() {
        let store = makeStore()
        let notices = (1...101).map { record($0, .dropped(reason: .tooOld, count: $0), at: Self.time + Int64($0)) }
        notices.forEach(store.save)

        XCTAssertEqual(store.prune(now: Self.time + 1_000), PruneResult())

        XCTAssertEqual(store.oldest(max: 200), Array(notices.dropFirst()))
    }

    func testPrune_DeletesALeftoverTemporaryFile() throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let leftover = folder.appendingPathComponent("\(Self.session)-7.json.tmp")
        try Data("{".utf8).write(to: leftover)
        let store = makeStore()

        XCTAssertEqual(store.prune(now: Self.time), PruneResult())

        XCTAssertFalse(FileManager.default.fileExists(atPath: leftover.path))
        XCTAssertEqual(store.count(), 0)
    }

    func testPrune_MergesDuplicates_BeforePruning() throws {
        let store = makeStore()
        let duplicate = TelemetryFixtures.sdkError()
        let first = record(1, duplicate, at: Self.time)
        let second = record(2, duplicate, at: Self.time + 1)
        let others = (3...101).map { record($0, .widgetOpened(widget: "Widget\($0)"), at: Self.time + Int64($0)) }
        ([first, second] + others).forEach(store.save)

        XCTAssertEqual(store.prune(now: Self.time + 1_000), PruneResult())

        XCTAssertEqual(store.count(), 100)
        let kept = try XCTUnwrap(store.oldest(max: 1).first)
        XCTAssertEqual(kept, first.with("paydock.occurrences", .int(2)))
        XCTAssertFalse(fileNames().contains("\(second.id).json"))
    }

    func testWithinBothCaps_CountAndPrune_DoNotReReadFilesAfterTheIndexIsBuilt() throws {
        let store = makeStore()
        let records = [record(1), record(2), record(3)]
        records.forEach(store.save)
        XCTAssertEqual(store.count(), 3)
        let damaged = folder.appendingPathComponent("\(records[1].id).json")
        try Data("not a record".utf8).write(to: damaged)

        XCTAssertEqual(store.count(), 3)
        XCTAssertEqual(store.prune(now: Self.time), PruneResult())
        XCTAssertEqual(store.count(), 3)
        XCTAssertTrue(FileManager.default.fileExists(atPath: damaged.path))
    }

    // MARK: - Unreadable files

    func testAFileThatDoesNotParse_IsSkippedAndDeleted_WhenTheIndexIsBuilt() throws {
        let readable = record(1)
        makeStore().save(readable)
        let unreadable = folder.appendingPathComponent("\(Self.session)-2.json")
        let misnamed = folder.appendingPathComponent("\(Self.session)-3.json")
        try Data("{\"timeUnixNano\":".utf8).write(to: unreadable)
        try OtlpLogEncoder.recordJSON(record(4)).write(to: misnamed)

        let store = makeStore()

        XCTAssertEqual(store.count(), 1)
        XCTAssertEqual(store.oldest(max: 10), [readable])
        XCTAssertEqual(fileNames(), ["\(readable.id).json"])
    }

    func testAFileThatDoesNotParse_IsSkippedAndDeleted_WhenOldestReadsIt() throws {
        let store = makeStore()
        let records = [record(1), record(2), record(3)]
        records.forEach(store.save)
        try Data("not a record".utf8).write(to: folder.appendingPathComponent("\(records[0].id).json"))

        XCTAssertEqual(store.oldest(max: 2), [records[1], records[2]])

        XCTAssertEqual(store.count(), 2)
        XCTAssertEqual(fileNames(), ["\(records[1].id).json", "\(records[2].id).json"])
    }

    /// A file the system will not let us read (as before the first unlock) is not a corrupt file: it is skipped and
    /// kept, and read once it can be.
    func testAFileThatCannotBeRead_IsSkippedAndKept_WhenTheIndexIsBuilt() throws {
        let kept = record(1)
        makeStore().save(kept)
        let url = folder.appendingPathComponent("\(kept.id).json")
        try lockFile(url)

        XCTAssertEqual(makeStore().count(), 0)
        XCTAssertEqual(fileNames(), ["\(kept.id).json"])

        try unlockFile(url)
        XCTAssertEqual(makeStore().oldest(max: 10), [kept])
    }

    func testAFileThatCannotBeRead_IsSkippedAndKept_WhenOldestReadsIt() throws {
        let store = makeStore()
        let records = [record(1), record(2)]
        records.forEach(store.save)
        let url = folder.appendingPathComponent("\(records[0].id).json")
        try lockFile(url)

        XCTAssertEqual(store.oldest(max: 10), [records[1]])
        XCTAssertEqual(store.count(), 2)
        XCTAssertEqual(fileNames(), ["\(records[0].id).json", "\(records[1].id).json"])

        try unlockFile(url)
        XCTAssertEqual(store.oldest(max: 10), records)
    }

    // MARK: - Crash save

    func testSaveCrash_WritesTheRecord_WithoutPruning() throws {
        let store = makeStore()
        let crash = record(1, TelemetryFixtures.crash())
        let old = record(2, at: Self.time - TelemetryLimits.recordMaxAgeMilliseconds - 1)
        store.save(old)

        XCTAssertTrue(store.saveCrash(crash, timeout: TelemetryLimits.crashLockTimeoutSeconds))

        XCTAssertEqual(fileNames(), ["\(crash.id).json", "\(old.id).json"])
        let data = try Data(contentsOf: folder.appendingPathComponent("\(crash.id).json"))
        XCTAssertEqual(OtlpLogEncoder.parseRecord(data), crash)
        XCTAssertEqual(store.count(), 2)
    }

    func testSaveCrash_BeforeTheIndexIsBuilt_IsCountedOnceItIs() {
        let store = makeStore()

        XCTAssertTrue(store.saveCrash(record(1, TelemetryFixtures.crash()), timeout: 0.5))

        XCTAssertEqual(store.count(), 1)
        XCTAssertEqual(store.oldest(max: 10).map(\.id), ["\(Self.session)-1"])
    }

    func testSaveCrash_WithoutADirectory_ReturnsFalse() {
        XCTAssertFalse(FileDurableStore { nil }.saveCrash(record(1), timeout: 0.5))
    }

    func testSaveCrash_GivesUp_WhenTheLockIsHeld() {
        let folder: URL = folder
        let resolving = DispatchSemaphore(value: 0)
        let gate = DispatchSemaphore(value: 0)
        let done = DispatchSemaphore(value: 0)
        // The directory is resolved under the store's lock: a resolution that waits holds the lock.
        let store = FileDurableStore {
            resolving.signal()
            gate.wait()
            return folder
        }
        DispatchQueue.global().async {
            _ = store.count()
            done.signal()
        }
        resolving.wait()

        let started = Date()
        let saved = store.saveCrash(record(1), timeout: 0.1)
        let waited = Date().timeIntervalSince(started)
        gate.signal()
        done.wait()

        XCTAssertFalse(saved)
        XCTAssertGreaterThanOrEqual(waited, 0.09)
        XCTAssertLessThan(waited, 5)
        XCTAssertEqual(store.count(), 0)
    }

    // MARK: - Directory

    func testNoDirectory_BeforeTheFirstSave() {
        let store = makeStore()

        XCTAssertEqual(store.count(), 0)
        XCTAssertEqual(store.oldest(max: 10), [])
        store.remove(ids: ["\(Self.session)-1"])
        XCTAssertEqual(store.prune(now: Self.time), PruneResult())
        XCTAssertFalse(FileManager.default.fileExists(atPath: folder.path))

        store.save(record(1))

        XCTAssertTrue(FileManager.default.fileExists(atPath: folder.path))
    }

    func testTheDirectory_IsResolvedOnFirstUse_Once() {
        let calls = CallCount()
        let folder: URL = folder
        let store = FileDurableStore { calls.increment(); return folder }
        XCTAssertEqual(calls.value, 0)

        XCTAssertEqual(store.count(), 0)
        store.save(record(1))
        _ = store.oldest(max: 1)

        XCTAssertEqual(calls.value, 1)
    }

    func testWithoutADirectory_NothingIsStored() {
        let store = FileDurableStore { nil }

        store.save(record(1))

        XCTAssertEqual(store.count(), 0)
        XCTAssertEqual(store.oldest(max: 1), [])
        XCTAssertEqual(store.prune(now: Self.time), PruneResult())
    }

    func testTheDirectory_IsExcludedFromBackup() throws {
        makeStore().save(record(1))

        let values = try folder.resourceValues(forKeys: [.isExcludedFromBackupKey])
        XCTAssertEqual(values.isExcludedFromBackup, true)
    }

    func testTheDefaultDirectory_IsPaydockTelemetry_InApplicationSupport() throws {
        let directory = try XCTUnwrap(FileDurableStore.defaultDirectory())

        XCTAssertEqual(directory.lastPathComponent, "paydock_telemetry")
        XCTAssertEqual(directory.deletingLastPathComponent().lastPathComponent, "Application Support")
    }

    // MARK: - Helpers

    private func makeStore() -> FileDurableStore {
        let folder: URL = folder
        return FileDurableStore { folder }
    }

    private func record(_ sequence: Int, _ event: TelemetryEvent = TelemetryFixtures.sdkError(),
                        at time: Int64 = FileDurableStoreTests.time) -> TelemetryRecord {
        let pending = PendingRecord(id: "\(Self.session)-\(sequence)", sessionId: Self.session, event: event, createdAt: time)
        return Allowlist.filter(RecordFactory.create(pending, connection: .wifi))
    }

    /// No read permission: `Data(contentsOf:)` fails as it does for a protected file.
    private func lockFile(_ url: URL) throws {
        try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: url.path)
        try XCTSkipIf((try? Data(contentsOf: url)) != nil, "this user can read a file without read permission")
    }

    private func unlockFile(_ url: URL) throws {
        try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: url.path)
    }

    private func fileNames() -> [String] {
        ((try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []).sorted()
    }
}
#endif
