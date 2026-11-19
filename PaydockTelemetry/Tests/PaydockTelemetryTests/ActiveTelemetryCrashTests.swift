//
//  ActiveTelemetryCrashTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

/// The runtime's crash wiring (R_03, R_09, R_11, R_13): the handler chain on a fake slot, never the process's; the
/// classifier built from a fixed image; diagnostics from a scripted source. `ActiveTelemetryTests` covers the rest.
final class ActiveTelemetryCrashTests: XCTestCase {
    typealias Handler = @convention(c) (NSException) -> Void

    /// The exception names the previous handler was given, in order.
    final class Forwarded: @unchecked Sendable {
        private let lock = NSLock()
        private var items: [String] = []

        var names: [String] {
            lock.lock()
            defer { lock.unlock() }
            return items
        }

        func append(_ name: String) {
            lock.lock()
            items.append(name)
            lock.unlock()
        }

        func reset() {
            lock.lock()
            items = []
            lock.unlock()
        }
    }

    private struct FixedIdGenerator: IdGenerator {
        let id: String

        func newId() -> String { id }
    }

    static let forwarded = Forwarded()

    private static let entryPoint: Handler = { _ in }
    private static let previousHandler: Handler = { ActiveTelemetryCrashTests.forwarded.append($0.name.rawValue) }

    private static let sessionId = "3f9a6c1e-2d47-4b8e-a5c0-7e1d9b4f2a63"
    private static let nextSessionId = "8c2e5a7d-1b94-4f3c-9e60-2a7d4c1b8e95"
    private static let now: Int64 = 1_793_852_047_512
    private static let twoHours: Int64 = 7_200_000
    private static let uuid = "C95ED3C1-F639-3822-BC5C-B2D03AFDD182"
    private static let appBase: UInt = 0x1_0000_0000
    private static let foundationBase: UInt = 0x1_8000_0000
    private static let throwSite: UInt = foundationBase + 0x5000
    /// The SDK's code in the app image: the SDK is linked statically.
    private static let sdkOffset: UInt64 = 0x1b5058
    private static let image = SdkImage(name: "ExampleApp", uuid: uuid, loadAddress: appBase)
    private static let points = [
        TypePoint(offset: 0x1b4000, module: "PaydockTelemetry"),
        TypePoint(offset: 0x1b6000, module: "MobileSDK"),
        TypePoint(offset: 0x225000, module: "ExampleApp")
    ]
    private static let currentBuild = FramePoints(imageName: "ExampleApp", uuid: uuid, sdkRanges: [0x1b4000...0x1b6000])
    private static let resolver = FixedAddressResolver([
        .init(path: "/private/var/containers/Bundle/Application/X/ExampleApp.app/ExampleApp", loadAddress: appBase),
        .init(path: "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", loadAddress: foundationBase,
              symbols: [throwSite: "__exceptionPreprocess"])
    ])

    private let dispatcher = ImmediateDispatcher()
    private let clock = FixedClock(ActiveTelemetryCrashTests.now)
    private let store = RecordingDurableStore()
    private let stateStore = InMemoryStateStore()
    private let reader = FixedSdkImageReader(image: ActiveTelemetryCrashTests.image, points: ActiveTelemetryCrashTests.points)
    private let source = ScriptedDiagnosticSource()
    private let slot = FakeExceptionHandlerSlot(ActiveTelemetryCrashTests.previousHandler)
    private lazy var chain = ExceptionHandlerChain(slot: slot, entryPoint: Self.entryPoint)

    override func setUp() {
        super.setUp()
        Self.forwarded.reset()
    }

    override func tearDown() {
        Self.forwarded.reset()
        super.tearDown()
    }

    // MARK: - The handler

    func testTheHandlerChain_IsInstalledByStartOnly_Once_OnTheCallingThread() {
        let serial = SerialTelemetryDispatcher()
        let gate = DispatchSemaphore(value: 0)
        XCTAssertTrue(serial.post { gate.wait() })
        let telemetry = makeTelemetry(dispatcher: serial)

        telemetry.report(TelemetryFixtures.crash())
        XCTAssertFalse(chain.isInstalled)
        XCTAssertEqual(slot.setCount, 0)

        telemetry.start()
        telemetry.start()

        XCTAssertTrue(chain.isInstalled, "start did not install the chain before its queue ran")
        XCTAssertEqual(slot.setCount, 1)
        XCTAssertEqual(reader.readCount, 0, "the queue ran before the check")
        gate.signal()
        drain(serial)
        XCTAssertEqual(slot.setCount, 1)
    }

    func testAnExceptionHandledAfterStart_IsStoredInThisSession_AndForwarded() throws {
        let telemetry = makeTelemetry()
        telemetry.start()

        chain.handle(sdkException())

        let saved = try XCTUnwrap(store.crashSaved.first)
        XCTAssertEqual(store.crashSaved.count, 1)
        XCTAssertEqual(saved.id, "\(Self.sessionId)-1")
        XCTAssertEqual(saved.sessionId, Self.sessionId)
        XCTAssertEqual(saved.value("paydock.crash.source"), .string("nsexception"))
        XCTAssertEqual(saved.value("paydock.exception.in_sdk"), .bool(true))
        XCTAssertEqual(Self.forwarded.names, ["NSInvalidArgumentException"])
        XCTAssertEqual(stateStore.savedMarker, CrashMarker(sessionId: Self.sessionId, imageUUID: Self.uuid,
                                                           topFrameOffset: Self.sdkOffset, time: Self.now))
        XCTAssertEqual(telemetry.sequence.next(), 2, "the record did not take its ID from the session's sequence")
    }

    // MARK: - The classifier

    func testStart_BuildsTheClassifierBeforeSubscribing() {
        let seenAtSubscription = Seen()
        let source = ScriptedDiagnosticSource { [reader, stateStore] in
            seenAtSubscription.set(reads: reader.readCount, saves: stateStore.framePointSaveCount)
        }
        let telemetry = makeTelemetry(source: source)

        telemetry.start()
        telemetry.start()

        XCTAssertEqual(source.startCount, 1)
        XCTAssertEqual(seenAtSubscription.reads, 1)
        XCTAssertEqual(seenAtSubscription.saves, 1)
    }

    func testTheRanges_AreSaved_CurrentBuildFirst_AtMostThree() {
        let saved = (1...3).map { index in
            FramePoints(imageName: "ExampleApp", uuid: "00000000-0000-4000-8000-00000000000\(index)",
                        sdkRanges: [UInt64(index)...UInt64(index + 10)])
        }
        let stateStore = InMemoryStateStore(builds: saved)
        let telemetry = makeTelemetry(stateStore: stateStore)

        telemetry.start()

        XCTAssertEqual(stateStore.savedBuilds, [Self.currentBuild, saved[0], saved[1]])
        XCTAssertEqual(stateStore.framePointSaveCount, 1)
    }

    func testUnchangedRanges_AreNotRewritten() {
        let stateStore = InMemoryStateStore(builds: [Self.currentBuild])
        let telemetry = makeTelemetry(stateStore: stateStore)

        telemetry.start()

        XCTAssertEqual(stateStore.savedBuilds, [Self.currentBuild])
        XCTAssertEqual(stateStore.framePointSaveCount, 0)
    }

    // MARK: - Diagnostics

    func testDeliveredDiagnostics_BecomeRecordsThroughTheReducer_LateStampedAtSend() throws {
        let exporter = ScriptedExporter()
        let telemetry = makeTelemetry(exporter: exporter)
        telemetry.start()
        let occurred = Self.now - Self.twoHours

        XCTAssertTrue(source.emit([MetricKitDiagnostic(
            kind: .crash, exceptionType: 1, signal: 11,
            frames: [DiagnosticFrame(binaryName: "ExampleApp", binaryUUID: Self.uuid, offset: Self.sdkOffset)],
            timeEnd: occurred
        )]))
        XCTAssertTrue(store.saved.isEmpty, "the diagnostics were handled off the queue")
        XCTAssertEqual(dispatcher.delayedMilliseconds, [0])
        dispatcher.runDelayed()

        let saved = try XCTUnwrap(store.saved.first)
        XCTAssertEqual(store.saved.count, 1)
        XCTAssertEqual(saved.id, "\(Self.sessionId)-1")
        XCTAssertEqual(saved.timeUnixMillis, occurred)
        XCTAssertEqual(saved.value("paydock.crash.source"), .string("metrickit"))
        XCTAssertEqual(saved.value("paydock.crash.reason"), .string("SIGSEGV"))
        XCTAssertEqual(saved.value("exception.type"), .string("EXC_BAD_ACCESS"))
        XCTAssertEqual(saved.value("paydock.exception.in_sdk"), .bool(true))
        XCTAssertEqual(telemetry.currentState().pending, 1)

        dispatcher.runDelayed()

        let sent = try XCTUnwrap(exporter.batches.first?.records.first)
        XCTAssertEqual(sent.id, saved.id)
        XCTAssertEqual(sent.timeUnixMillis, Self.now)
        XCTAssertEqual(sent.value(SendStamp.occurredAtKey), .string(UtcTimestamp.iso8601(occurred)))
    }

    /// The failure mode "a crash is recorded twice": the handler's record of an Objective-C exception from SDK code,
    /// then, on the next launch, MetricKit's SIGABRT report of the same crash, give one stored crash.
    func testAnObjectiveCExceptionCrashFromSdkCode_YieldsOneRecord_NotTwo() throws {
        let crashed = makeTelemetry(exporter: ScriptedExporter(fallback: .retry(retryAfterMilliseconds: nil)))
        crashed.start()
        chain.handle(sdkException())
        let marker = try XCTUnwrap(stateStore.savedMarker)
        XCTAssertEqual(store.crashSaved.count, 1)

        let nextLaunchSource = ScriptedDiagnosticSource()
        let nextLaunch = makeTelemetry(exporter: ScriptedExporter(fallback: .retry(retryAfterMilliseconds: nil)),
                                       source: nextLaunchSource, sessionId: Self.nextSessionId, installsHandlers: false)
        nextLaunch.start()
        XCTAssertTrue(nextLaunchSource.emit([MetricKitDiagnostic(
            kind: .crash, exceptionType: 10, signal: 6,
            frames: [
                DiagnosticFrame(binaryName: "libsystem_kernel.dylib", binaryUUID: "5C1F0B2A-7E3D-4A96-B8C4-1D2E3F4A5B6C",
                                offset: 0x9a40),
                DiagnosticFrame(binaryName: "ExampleApp", binaryUUID: marker.imageUUID, offset: marker.topFrameOffset)
            ],
            timeEnd: Self.now - 1_000
        )]))
        dispatcher.runDelayed()

        let crashes = store.oldest(max: 100).filter { $0.eventName == "paydock.crash" }
        XCTAssertEqual(crashes.map(\.id), ["\(Self.sessionId)-1"])
        XCTAssertTrue(store.saved.isEmpty, "the MetricKit report of the recorded crash was stored")
        XCTAssertNil(stateStore.savedMarker)
        XCTAssertEqual(stateStore.markerClearCount, 1)
    }

    // MARK: - Report site (R_03)

    /// The site's addresses are described as image offsets (a system symbol kept) and classified on the queue.
    func testReportWithASite_StoresAnSdkError_WithOffsetFrames_AndInSdkFromTheClassifier() throws {
        let telemetry = makeTelemetry()
        telemetry.start()
        let site = ReportSite(returnAddresses: [Self.appBase + UInt(Self.sdkOffset), Self.throwSite + 164],
                              threadName: "main")

        telemetry.report(.sdkError(error: TelemetryFixtures.info("MobileSDK.SilentFailure"), errorCode: "SAMPLE_CODE",
                                   widget: "CardDetailsWidget"), site: site)

        let saved = try XCTUnwrap(store.saved.first)
        XCTAssertEqual(store.saved.count, 1)
        XCTAssertEqual(saved.value("event.name"), .string("paydock.error"))
        XCTAssertEqual(saved.value("paydock.error.kind"), .string("sdk_error"))
        XCTAssertEqual(saved.value("exception.stacktrace"), .string(
            "MobileSDK.SilentFailure\n\tat ExampleApp 0x1b5058\n\tat CoreFoundation __exceptionPreprocess + 164"
        ))
        XCTAssertEqual(saved.value("paydock.exception.in_sdk"), .bool(true))
    }

    func testReportWithASiteOutsideTheSdk_StoresInSdkFalse() throws {
        let telemetry = makeTelemetry()
        telemetry.start()
        let site = ReportSite(returnAddresses: [Self.throwSite + 164, Self.appBase + 0x225100], threadName: nil)

        telemetry.report(.uncaughtException(error: TelemetryFixtures.info("Sample.Error")), site: site)

        let saved = try XCTUnwrap(store.saved.first)
        XCTAssertEqual(saved.value("paydock.error.kind"), .string("uncaught"))
        XCTAssertEqual(saved.value("paydock.exception.in_sdk"), .bool(false))
    }

    /// The failure mode "a crash is recorded twice", with SDK error reporting wired: an Objective-C exception from SDK
    /// code handled by the crash path gives exactly one `paydock.crash` record and no `paydock.error`.
    func testOneSdkCrash_GivesOneCriticalRecord_AndNoError() {
        let telemetry = makeTelemetry(exporter: ScriptedExporter(fallback: .retry(retryAfterMilliseconds: nil)))
        telemetry.start()

        chain.handle(sdkException())

        let records = store.oldest(max: 100)
        XCTAssertEqual(records.filter { $0.eventName == "paydock.crash" }.count, 1)
        XCTAssertEqual(records.filter { $0.eventName == "paydock.error" }.count, 0)
        XCTAssertEqual(store.crashSaved.count, 1)
        XCTAssertTrue(store.saved.isEmpty, "the crash also went through the reducer")
        XCTAssertEqual(Self.forwarded.names, ["NSInvalidArgumentException"])
    }

    // MARK: - The main queue

    func testTheMainQueueScheduler_RunsTheTaskOnTheMainThread() {
        let ran = expectation(description: "the task ran")
        let onMain = Seen()

        ActiveTelemetry.mainQueue(1) {
            onMain.set(reads: Thread.isMainThread ? 1 : 0, saves: 0)
            ran.fulfill()
        }

        wait(for: [ran], timeout: 5)
        XCTAssertEqual(onMain.reads, 1)
    }

    // MARK: - Helpers

    /// What a callback saw, read after it ran.
    private final class Seen: @unchecked Sendable {
        private let lock = NSLock()
        private var values: (reads: Int, saves: Int) = (-1, -1)

        var reads: Int { locked { values.reads } }
        var saves: Int { locked { values.saves } }

        func set(reads: Int, saves: Int) {
            locked { values = (reads, saves) }
        }

        private func locked<T>(_ body: () -> T) -> T {
            lock.lock()
            defer { lock.unlock() }
            return body()
        }
    }

    private func makeTelemetry(
        exporter: any Exporter = ScriptedExporter(),
        dispatcher: (any TelemetryDispatcher)? = nil,
        stateStore: InMemoryStateStore? = nil,
        source: ScriptedDiagnosticSource? = nil,
        sessionId: String = ActiveTelemetryCrashTests.sessionId,
        installsHandlers: Bool = true
    ) -> ActiveTelemetry {
        ActiveTelemetry(
            endpoint: TelemetryFixtures.endpoint,
            deviceContextProvider: FakeDeviceContextProvider(),
            clock: clock,
            monotonic: FixedMonotonicClock(),
            idGenerator: FixedIdGenerator(id: sessionId),
            dispatcher: dispatcher ?? self.dispatcher,
            ports: ActiveTelemetry.Ports(
                store: store,
                exporter: exporter,
                connection: RecordingConnectionMonitor(.wifi),
                clockOffset: ClockOffset(clock: clock),
                retryPolicy: RetryPolicy(random: FixedRandom().function),
                stateStore: stateStore ?? self.stateStore,
                imageReader: reader,
                diagnostics: source ?? self.source,
                exceptionHandlers: installsHandlers ? chain : nil,
                resolver: Self.resolver
            ),
            scheduleOnMain: { _, _ in }
        )
    }

    /// `__exceptionPreprocess + 164`, then a frame in the SDK's code.
    private func sdkException() -> ScriptedException {
        ScriptedException(name: "NSInvalidArgumentException", reason: "test",
                          addresses: [Self.throwSite + 164, Self.appBase + UInt(Self.sdkOffset)])
    }

    /// Waits until every task posted to the queue so far has run.
    private func drain(_ serial: SerialTelemetryDispatcher) {
        let done = expectation(description: "the queue drained")
        serial.post { done.fulfill() }
        wait(for: [done], timeout: 5)
    }
}
