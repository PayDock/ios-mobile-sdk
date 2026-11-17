//
//  FileStateStoreTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation
import PaydockTelemetry
import XCTest

/// R_07, R_15: the classifier's ranges and the crash marker, in `state/` of the telemetry directory. Every test runs in
/// its own temporary directory, removed afterwards.
final class FileStateStoreTests: XCTestCase {

    private static let session = "0b6f2c4e-93a1-4d7e-8f25-6c1d9e3a7b40"
    private static let uuid = "C95ED3C1-F639-3822-BC5C-B2D03AFDD182"
    private static let previousUUID = "4A1B2C3D-0000-4000-8000-00000000A0B1"

    private var temporary: TemporaryDirectory!
    private var folder: URL!

    override func setUpWithError() throws {
        temporary = try TemporaryDirectory()
        folder = temporary.child(FileDurableStore.directoryName)
    }

    override func tearDown() {
        temporary.remove()
    }

    // MARK: - Round trips

    func testFramePoints_RoundTrip() {
        let store = makeStore()
        let builds = [
            FramePoints(imageName: "ExampleApp", uuid: Self.uuid, sdkRanges: [0x1000...0x1fff, 0x3000...0x3000]),
            FramePoints(imageName: "ExampleApp", uuid: Self.previousUUID, sdkRanges: [0x2000...0x2800])
        ]

        store.saveFramePoints(builds)

        XCTAssertEqual(store.loadFramePoints(), builds)
        XCTAssertEqual(makeStore().loadFramePoints(), builds)
    }

    func testTheCrashMarker_RoundTrips() {
        let store = makeStore()

        XCTAssertTrue(store.saveCrashMarker(marker(), timeout: TelemetryLimits.crashLockTimeoutSeconds))

        XCTAssertEqual(store.loadCrashMarker(), marker())
        XCTAssertEqual(makeStore().loadCrashMarker(), marker())
    }

    func testMissingFiles_ReadEmptyAndNil() {
        let store = makeStore()

        XCTAssertEqual(store.loadFramePoints(), [])
        XCTAssertNil(store.loadCrashMarker())
    }

    func testClearCrashMarker_RemovesTheFile() {
        let store = makeStore()
        store.saveCrashMarker(marker(), timeout: 0.5)
        XCTAssertTrue(FileManager.default.fileExists(atPath: file("crash-marker.json").path))

        store.clearCrashMarker()

        XCTAssertFalse(FileManager.default.fileExists(atPath: file("crash-marker.json").path))
        XCTAssertNil(store.loadCrashMarker())
        store.clearCrashMarker()
    }

    // MARK: - Unreadable files

    func testAnUnreadableFramePointsFile_IsRemoved_AndReadsEmpty() throws {
        try writeGarbage("frame-points.json")

        XCTAssertEqual(makeStore().loadFramePoints(), [])
        XCTAssertFalse(FileManager.default.fileExists(atPath: file("frame-points.json").path))
    }

    func testAnUnreadableCrashMarkerFile_IsRemoved_AndReadsNil() throws {
        try writeGarbage("crash-marker.json")

        XCTAssertNil(makeStore().loadCrashMarker())
        XCTAssertFalse(FileManager.default.fileExists(atPath: file("crash-marker.json").path))
    }

    // MARK: - Directory

    func testNothingIsCreated_BeforeTheFirstWrite() {
        let store = makeStore()

        _ = store.loadFramePoints()
        _ = store.loadCrashMarker()
        store.clearCrashMarker()

        XCTAssertFalse(FileManager.default.fileExists(atPath: folder.path))

        store.saveFramePoints([])

        XCTAssertTrue(FileManager.default.fileExists(atPath: folder.path))
    }

    func testTheFiles_LiveUnderState() throws {
        let store = makeStore()

        store.saveFramePoints([FramePoints(imageName: "ExampleApp", uuid: Self.uuid, sdkRanges: [0x10...0x20])])
        store.saveCrashMarker(marker(), timeout: 0.5)

        XCTAssertEqual(FileStateStore.subdirectory, "state")
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: folder.path), ["state"])
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: folder.appendingPathComponent("state").path).sorted(),
                       ["crash-marker.json", "frame-points.json"])
    }

    func testTheTelemetryDirectory_IsExcludedFromBackup() throws {
        makeStore().saveFramePoints([])

        let values = try folder.resourceValues(forKeys: [.isExcludedFromBackupKey])
        XCTAssertEqual(values.isExcludedFromBackup, true)
    }

    func testWithoutADirectory_NothingIsKept() {
        let store = FileStateStore { nil }

        store.saveFramePoints([FramePoints(imageName: "ExampleApp", uuid: Self.uuid, sdkRanges: [0x10...0x20])])

        XCTAssertFalse(store.saveCrashMarker(marker(), timeout: 0.5))
        XCTAssertEqual(store.loadFramePoints(), [])
        XCTAssertNil(store.loadCrashMarker())
    }

    func testAFileDurableStoreOnTheSameDirectory_CountsNoRecord() {
        let stateStore = makeStore()
        stateStore.saveFramePoints([FramePoints(imageName: "ExampleApp", uuid: Self.uuid, sdkRanges: [0x10...0x20])])
        stateStore.saveCrashMarker(marker(), timeout: 0.5)
        let folder: URL = folder

        let recordStore = FileDurableStore { folder }

        XCTAssertEqual(recordStore.count(), 0)
        XCTAssertEqual(recordStore.oldest(max: 10), [])
        XCTAssertEqual(recordStore.prune(now: marker().time), PruneResult())
        XCTAssertNotNil(stateStore.loadCrashMarker())
    }

    // MARK: - The crash path

    func testTheCrashMarkerWrite_GivesUp_WhenTheLockIsHeld() {
        let folder: URL = folder
        let resolving = DispatchSemaphore(value: 0)
        let gate = DispatchSemaphore(value: 0)
        let done = DispatchSemaphore(value: 0)
        // The directory is resolved under the store's lock: a resolution that waits holds the lock.
        let store = FileStateStore {
            resolving.signal()
            gate.wait()
            return folder
        }
        DispatchQueue.global().async {
            _ = store.loadFramePoints()
            done.signal()
        }
        resolving.wait()

        let started = Date()
        let saved = store.saveCrashMarker(marker(), timeout: 0.1)
        let waited = Date().timeIntervalSince(started)
        gate.signal()
        done.wait()

        XCTAssertFalse(saved)
        XCTAssertGreaterThanOrEqual(waited, 0.09)
        XCTAssertLessThan(waited, 5)
        XCTAssertNil(store.loadCrashMarker())
        XCTAssertFalse(FileManager.default.fileExists(atPath: folder.path))
    }

    // MARK: - Helpers

    private func makeStore() -> FileStateStore {
        let folder: URL = folder
        return FileStateStore { folder }
    }

    private func marker() -> CrashMarker {
        CrashMarker(sessionId: Self.session, imageUUID: Self.uuid, topFrameOffset: 0x1b5058, time: 1_793_852_047_512)
    }

    private func file(_ name: String) -> URL {
        folder.appendingPathComponent("state", isDirectory: true).appendingPathComponent(name)
    }

    private func writeGarbage(_ name: String) throws {
        let state = folder.appendingPathComponent("state", isDirectory: true)
        try FileManager.default.createDirectory(at: state, withIntermediateDirectories: true)
        try Data("{not json".utf8).write(to: state.appendingPathComponent(name))
    }
}
#endif
