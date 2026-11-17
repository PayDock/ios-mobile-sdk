//
//  CrashRecorderTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation
import PaydockTelemetry
import XCTest

/// R_04, R_05, R_07 (Android `CrashRecorderTest`): the recorder on the crashing thread, with scripted return addresses,
/// a fixed resolver and in-memory stores.
final class CrashRecorderTests: XCTestCase {

    private static let session = "7e41d9c2-8b05-4f6a-a3d1-0c9e2b7f5a68"
    private static let uuid = "C95ED3C1-F639-3822-BC5C-B2D03AFDD182"
    private static let appBase: UInt = 0x1_0000_0000
    private static let foundationBase: UInt = 0x1_8000_0000
    private static let objcBase: UInt = 0x1_8100_0000
    private static let uikitBase: UInt = 0x1_8200_0000
    private static let throwSite: UInt = foundationBase + 0x5000
    private static let objcThrow: UInt = objcBase + 0x2000
    /// The SDK's code in the app image: the SDK is linked statically.
    private static let sdkOffset: UInt = 0x1b5058
    private static let appOffset: UInt = 0x2251a8
    private static let sdkImage = SdkImage(name: "ExampleApp", uuid: uuid, loadAddress: appBase)
    private static let resolver = FixedAddressResolver([
        .init(path: "/private/var/containers/Bundle/Application/X/ExampleApp.app/ExampleApp", loadAddress: appBase),
        .init(path: "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", loadAddress: foundationBase,
              symbols: [throwSite: "__exceptionPreprocess"]),
        .init(path: "/usr/lib/libobjc.A.dylib", loadAddress: objcBase, symbols: [objcThrow: "objc_exception_throw"]),
        .init(path: "/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore", loadAddress: uikitBase)
    ])

    private var store: RecordingDurableStore!
    private var stateStore: InMemoryStateStore!
    private var sequence: RecordSequence!
    private var box: FrameClassifierBox!
    private var connection: RecordingConnectionMonitor!
    private var clock: FixedClock!

    override func setUp() {
        store = RecordingDurableStore()
        stateStore = InMemoryStateStore()
        sequence = RecordSequence()
        box = FrameClassifierBox()
        box.current = FrameClassifier(builds: [
            FramePoints(imageName: "ExampleApp", uuid: Self.uuid, sdkRanges: [0x1b4000...0x1b6000])
        ])
        connection = RecordingConnectionMonitor(.wifi)
        clock = FixedClock(1_793_852_047_512)
    }

    // MARK: - The record

    func testAnSdkException_StoresAnNSExceptionCrashRecord_InSdk() throws {
        makeRecorder().record(exception(top: Self.appBase + Self.sdkOffset))

        let saved = try XCTUnwrap(store.crashSaved.first)
        XCTAssertEqual(store.crashSaved.count, 1)
        XCTAssertEqual(saved.id, "\(Self.session)-1")
        XCTAssertEqual(saved.timeUnixMillis, clock.now())
        XCTAssertEqual(saved.severity, .fatal)
        XCTAssertEqual(saved.eventName, "paydock.crash")
        XCTAssertEqual(saved.sessionId, Self.session)
        XCTAssertEqual(saved.value("paydock.crash.source"), .string("nsexception"))
        XCTAssertEqual(saved.value("paydock.crash.kind"), .string("exception"))
        XCTAssertEqual(saved.value("paydock.crash.reason"), .string("NSInvalidArgumentException"))
        XCTAssertEqual(saved.value("exception.type"), .string("NSInvalidArgumentException"))
        XCTAssertEqual(saved.value("paydock.exception.in_sdk"), .bool(true))
        XCTAssertEqual(saved.value("thread.name"), .string("main"))
        XCTAssertEqual(saved.value("network.connection.type"), .string("wifi"))
        XCTAssertEqual(saved.value("exception.stacktrace"), .string(
            "NSInvalidArgumentException\n\tat CoreFoundation __exceptionPreprocess + 164\n"
                + "\tat libobjc.A.dylib objc_exception_throw + 60\n\tat ExampleApp 0x1b5058"
        ))
        XCTAssertEqual(saved, Allowlist.filter(saved))
    }

    func testAnAppException_FramesOutsideTheRanges_IsNotInSdk() throws {
        makeRecorder().record(exception(top: Self.appBase + Self.appOffset))

        let saved = try XCTUnwrap(store.crashSaved.first)
        XCTAssertEqual(saved.value("paydock.exception.in_sdk"), .bool(false))
    }

    func testNoClassifierYet_InSdkIsAbsent() throws {
        box.current = nil

        makeRecorder().record(exception(top: Self.appBase + Self.sdkOffset))

        let saved = try XCTUnwrap(store.crashSaved.first)
        XCTAssertNil(saved.value("paydock.exception.in_sdk"))
        XCTAssertEqual(saved.eventName, "paydock.crash")
    }

    func testAnUnsavedBuildOfTheSdkImage_InSdkIsAbsent() throws {
        let rebuilt = SdkImage(name: "ExampleApp", uuid: "4A1B2C3D-0000-4000-8000-00000000A0B1", loadAddress: Self.appBase)

        makeRecorder(image: rebuilt).record(exception(top: Self.appBase + Self.sdkOffset))

        let saved = try XCTUnwrap(store.crashSaved.first)
        XCTAssertNil(saved.value("paydock.exception.in_sdk"))
    }

    func testFramesBeyond64_AreLeftOut() throws {
        let addresses = (0..<80).map { Self.appBase + Self.appOffset + UInt($0) * 4 }

        makeRecorder().record(ScriptedException(name: "NSRangeException", addresses: addresses))

        let saved = try XCTUnwrap(store.crashSaved.first)
        guard case let .string(stacktrace) = saved.value("exception.stacktrace") else {
            return XCTFail("no stack trace")
        }
        XCTAssertEqual(stacktrace.components(separatedBy: "\n\tat ").count - 1, 64)
    }

    func testAReasonHoldingACardLikeNumber_AppearsNowhere() throws {
        let sample = SensitiveSamples.exception()
        let leaking = ScriptedException(name: sample.name.rawValue, reason: sample.reason, userInfo: sample.userInfo,
                                        addresses: [Self.throwSite, Self.appBase + Self.sdkOffset])

        makeRecorder().record(leaking)

        let saved = try XCTUnwrap(store.crashSaved.first)
        let json = try XCTUnwrap(String(bytes: OtlpLogEncoder.recordJSON(saved), encoding: .utf8))
        for forbidden in SensitiveSamples.forbiddenInOutput {
            XCTAssertFalse(json.contains(forbidden))
        }
        XCTAssertEqual(saved.value("exception.type"), .string("SampleInvalidArgumentException"))
    }

    func testTheId_ComesFromTheSharedSequence() throws {
        _ = sequence.next()
        _ = sequence.next()

        makeRecorder().record(exception(top: Self.appBase + Self.sdkOffset))

        XCTAssertEqual(try XCTUnwrap(store.crashSaved.first).id, "\(Self.session)-3")
        XCTAssertEqual(sequence.next(), 4)
    }

    func testAConnectionTypeNotKnown_ReadsUnknown() throws {
        connection.connectionType = .unknown

        makeRecorder().record(exception(top: Self.appBase + Self.sdkOffset))

        XCTAssertEqual(try XCTUnwrap(store.crashSaved.first).value("network.connection.type"), .string("unknown"))
    }

    func testOffTheMainThread_TheThreadNameIsTheThreadsOwn_OrAbsent() throws {
        let recorder = makeRecorder()
        let done = DispatchSemaphore(value: 0)
        let named = Thread {
            recorder.record(self.exception(top: Self.appBase + Self.sdkOffset))
            done.signal()
        }
        named.name = "worker"
        named.start()
        done.wait()
        let unnamed = Thread {
            recorder.record(self.exception(top: Self.appBase + Self.sdkOffset))
            done.signal()
        }
        unnamed.start()
        done.wait()

        let saved = store.crashSaved
        XCTAssertEqual(saved.count, 2)
        XCTAssertEqual(saved.first?.value("thread.name"), .string("worker"))
        XCTAssertNil(saved.last?.value("thread.name"))
    }

    func testARecordRejectedByTheAllowlist_IsNotStored() {
        makeRecorder(sessionId: "not-a-session-id").record(exception(top: Self.appBase + Self.sdkOffset))

        XCTAssertEqual(store.crashSaved, [])
        XCTAssertEqual(store.calls.count, 0)
        XCTAssertNil(stateStore.savedMarker)
    }

    func testItNeverPrunesOrReadsTheStore() {
        makeRecorder().record(exception(top: Self.appBase + Self.sdkOffset))

        XCTAssertEqual(store.calls.count, 1)
        XCTAssertEqual(store.crashSaved.count, 1)
        XCTAssertEqual(store.saved, [])
        XCTAssertEqual(store.pruneTimes, [])
    }

    func testAStoreWhoseLockIsHeld_GivesUpAfterTheTimeout_AndReturns() {
        store.holdLock()

        let started = Date()
        makeRecorder().record(exception(top: Self.appBase + Self.sdkOffset))
        let waited = Date().timeIntervalSince(started)
        store.releaseLock()

        XCTAssertGreaterThanOrEqual(waited, TelemetryLimits.crashLockTimeoutSeconds * 0.9)
        XCTAssertLessThan(waited, 5)
        XCTAssertEqual(store.crashSaved, [])
        XCTAssertNil(stateStore.savedMarker, "no record, no marker: the next launch's report stands for the crash")
    }

    func testAStateStoreWhoseLockIsHeld_KeepsTheRecord_AndReturns() {
        stateStore.holdLock()

        let started = Date()
        makeRecorder().record(exception(top: Self.appBase + Self.sdkOffset))
        let waited = Date().timeIntervalSince(started)
        stateStore.releaseLock()

        XCTAssertLessThan(waited, 5)
        XCTAssertEqual(store.crashSaved.count, 1)
        XCTAssertNil(stateStore.savedMarker)
    }

    // MARK: - The marker

    func testTheMarker_HoldsTheSession_TheUUID_TheTopSdkImageFramesOffset_AndTheTime() {
        let addresses = [Self.throwSite, Self.objcThrow, Self.appBase + Self.appOffset, Self.appBase + Self.sdkOffset]

        makeRecorder().record(ScriptedException(name: "NSInvalidArgumentException", addresses: addresses))

        XCTAssertEqual(stateStore.savedMarker, CrashMarker(sessionId: Self.session, imageUUID: Self.uuid,
                                                           topFrameOffset: UInt64(Self.appOffset), time: clock.now()))
    }

    func testNoFrameInTheSdkImage_NoMarker() throws {
        let addresses = [Self.throwSite, Self.objcThrow, Self.uikitBase + 0x58f740]

        makeRecorder().record(ScriptedException(name: "NSInvalidArgumentException", addresses: addresses))

        XCTAssertEqual(try XCTUnwrap(store.crashSaved.first).value("paydock.exception.in_sdk"), .bool(false))
        XCTAssertNil(stateStore.savedMarker)
        XCTAssertEqual(stateStore.markerSaveCount, 0)
    }

    func testNoSdkImage_NoMarker_AndNoUUIDToClassifyBy() throws {
        makeRecorder(image: nil).record(exception(top: Self.appBase + Self.sdkOffset))

        XCTAssertNil(try XCTUnwrap(store.crashSaved.first).value("paydock.exception.in_sdk"))
        XCTAssertNil(stateStore.savedMarker)
    }

    // MARK: - Helpers

    private func makeRecorder(sessionId: String = CrashRecorderTests.session,
                              image: SdkImage? = CrashRecorderTests.sdkImage) -> CrashRecorder {
        CrashRecorder(sessionId: sessionId, sequence: sequence, store: store, stateStore: stateStore,
                      image: { image }, classifier: box, resolver: Self.resolver, connection: connection, clock: clock)
    }

    /// `__exceptionPreprocess + 164`, `objc_exception_throw + 60`, then the given frame.
    private func exception(top: UInt) -> ScriptedException {
        ScriptedException(name: "NSInvalidArgumentException", reason: "test",
                          addresses: [Self.throwSite + 164, Self.objcThrow + 60, top])
    }
}
#endif
