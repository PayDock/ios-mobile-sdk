//
//  ExceptionHandlerChainTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation
import PaydockTelemetry
import XCTest

/// R_03, R_06 (Android `ChainedCrashHandlerTest`, `CrashHandlerInstallerTest`): the chain on a fake slot, never the
/// process's. A previous handler is a C function, so it reports through the static log.
final class ExceptionHandlerChainTests: XCTestCase {
    typealias Handler = @convention(c) (NSException) -> Void

    /// What the previous handlers and the recorders did, in order.
    final class Log: @unchecked Sendable {
        private let lock = NSLock()
        private var entries: [String] = []
        private var exceptions: [NSException] = []
        private var chainUnderTest: ExceptionHandlerChain?

        var all: [String] { locked { entries } }
        var forwardedExceptions: [NSException] { locked { exceptions } }
        var chain: ExceptionHandlerChain? {
            get { locked { chainUnderTest } }
            set { locked { chainUnderTest = newValue } }
        }

        func append(_ entry: String) {
            locked { entries.append(entry) }
        }

        func forwarded(_ exception: NSException) {
            locked {
                entries.append("forwarded \(exception.name.rawValue)")
                exceptions.append(exception)
            }
        }

        func reset() {
            locked {
                entries = []
                exceptions = []
                chainUnderTest = nil
            }
        }

        private func locked<T>(_ body: () -> T) -> T {
            lock.lock()
            defer { lock.unlock() }
            return body()
        }
    }

    static let log = Log()

    private static let entryPoint: Handler = { ExceptionHandlerChainTests.log.append("entry \($0.name.rawValue)") }
    private static let previousHandler: Handler = { ExceptionHandlerChainTests.log.forwarded($0) }
    /// A previous handler that hands the exception back to the chain, as a handler installed over it would.
    private static let reenteringHandler: Handler = { exception in
        ExceptionHandlerChainTests.log.chain?.handle(exception)
        ExceptionHandlerChainTests.log.forwarded(exception)
    }

    override func setUp() {
        Self.log.reset()
    }

    override func tearDown() {
        Self.log.reset()
    }

    // MARK: - Handling

    func testRecordsFirst_ThenCallsThePreviousHandler_WithTheSameException() {
        let chain = makeChain(previous: Self.previousHandler)
        chain.install(loggingRecorder())
        let exception = NSException(name: NSExceptionName("SampleException"), reason: "test", userInfo: nil)

        chain.handle(exception)

        XCTAssertEqual(Self.log.all, ["recorded SampleException", "forwarded SampleException"])
        XCTAssertEqual(Self.log.forwardedExceptions.count, 1)
        XCTAssertTrue(Self.log.forwardedExceptions.first === exception)
    }

    func testARecorderThatSavesNothing_StillForwards() {
        let chain = makeChain(previous: Self.previousHandler)
        chain.install(CrashRecorder(sessionId: "7e41d9c2-8b05-4f6a-a3d1-0c9e2b7f5a68", sequence: RecordSequence(),
                                    store: NoOpDurableStore(), stateStore: NoOpTelemetryStateStore(), image: { nil },
                                    classifier: FrameClassifierBox(), resolver: FixedAddressResolver(),
                                    connection: RecordingConnectionMonitor(), clock: FixedClock()))

        chain.handle(sample("SampleException"))

        XCTAssertEqual(Self.log.all, ["forwarded SampleException"])
    }

    func testNoPreviousHandler_NothingElseIsCalled() {
        let chain = makeChain(previous: nil)
        chain.install(loggingRecorder())

        chain.handle(sample("SampleException"))

        XCTAssertEqual(Self.log.all, ["recorded SampleException"])
    }

    func testReenteredOnTheSameThread_FromThePreviousHandler_RecordsOnce_AndForwardsOnce() {
        let chain = makeChain(previous: Self.reenteringHandler)
        Self.log.chain = chain
        chain.install(loggingRecorder())

        chain.handle(sample("SampleException"))

        XCTAssertEqual(Self.log.all, ["recorded SampleException", "forwarded SampleException"])
    }

    func testReenteredOnTheSameThread_FromTheRecorder_RecordsOnce_AndForwardsOnce() {
        let chain = makeChain(previous: Self.previousHandler)
        chain.install(RecordingCrashRecorder { exception in
            ExceptionHandlerChainTests.log.append("recorded \(exception.name.rawValue)")
            chain.handle(exception)
        })

        chain.handle(sample("SampleException"))

        XCTAssertEqual(Self.log.all, ["recorded SampleException", "forwarded SampleException"])
    }

    func testAfterALoopEnded_TheNextExceptionIsRecordedAgain() {
        let chain = makeChain(previous: Self.reenteringHandler)
        Self.log.chain = chain
        chain.install(loggingRecorder())

        chain.handle(sample("FirstException"))
        chain.handle(sample("SecondException"))

        XCTAssertEqual(Self.log.all, ["recorded FirstException", "forwarded FirstException",
                                      "recorded SecondException", "forwarded SecondException"])
    }

    func testAnotherThread_WhileOneIsHandled_IsStillRecordedAndForwarded() {
        let chain = makeChain(previous: Self.previousHandler)
        let other = sample("OtherThreadException")
        chain.install(RecordingCrashRecorder { exception in
            ExceptionHandlerChainTests.log.append("recorded \(exception.name.rawValue)")
            guard exception.name.rawValue == "FirstException" else {
                return
            }
            let done = DispatchSemaphore(value: 0)
            Thread {
                chain.handle(other)
                done.signal()
            }.start()
            done.wait()
        })

        chain.handle(sample("FirstException"))

        XCTAssertEqual(Self.log.all, ["recorded FirstException", "recorded OtherThreadException",
                                      "forwarded OtherThreadException", "forwarded FirstException"])
    }

    func testTheCurrentRecorder_IsUsed() {
        let chain = makeChain(previous: nil)
        let first = RecordingCrashRecorder()
        let second = RecordingCrashRecorder()
        chain.install(first)
        chain.install(second)

        chain.handle(sample("SampleException"))

        XCTAssertEqual(first.recorded, [])
        XCTAssertEqual(second.recorded, ["SampleException"])
    }

    // MARK: - Install

    func testInstall_ChainsTheSlotsCurrentHandler() throws {
        let slot = FakeExceptionHandlerSlot(Self.previousHandler)
        let chain = ExceptionHandlerChain(slot: slot, entryPoint: Self.entryPoint)
        XCTAssertFalse(chain.isInstalled)

        chain.install(RecordingCrashRecorder())

        XCTAssertTrue(chain.isInstalled)
        XCTAssertTrue(Self.isSame(try XCTUnwrap(chain.previous), Self.previousHandler))
        XCTAssertTrue(Self.isSame(try XCTUnwrap(slot.get()), Self.entryPoint))
    }

    func testInstallingTwice_MakesOneLink_AndTheSecondRecorderWins() throws {
        let slot = FakeExceptionHandlerSlot(Self.previousHandler)
        let chain = ExceptionHandlerChain(slot: slot, entryPoint: Self.entryPoint)
        let first = RecordingCrashRecorder()
        let second = RecordingCrashRecorder()

        chain.install(first)
        chain.install(second)
        chain.handle(sample("SampleException"))

        XCTAssertEqual(slot.setCount, 1)
        XCTAssertTrue(Self.isSame(try XCTUnwrap(chain.previous), Self.previousHandler))
        XCTAssertEqual(first.recorded, [])
        XCTAssertEqual(second.recorded, ["SampleException"])
        XCTAssertEqual(Self.log.all, ["forwarded SampleException"])
    }

    func testAnEmptySlot_GivesALinkWithNoPrevious() throws {
        let slot = FakeExceptionHandlerSlot()
        let chain = ExceptionHandlerChain(slot: slot, entryPoint: Self.entryPoint)

        chain.install(RecordingCrashRecorder())

        XCTAssertTrue(chain.isInstalled)
        XCTAssertNil(chain.previous)
        XCTAssertTrue(Self.isSame(try XCTUnwrap(slot.get()), Self.entryPoint))
    }

    func testASlotThatRefusesTheSet_IsRetriedOnTheNextInstall() throws {
        let slot = FakeExceptionHandlerSlot(Self.previousHandler)
        slot.refusesSet = true
        let chain = ExceptionHandlerChain(slot: slot, entryPoint: Self.entryPoint)

        chain.install(RecordingCrashRecorder())

        XCTAssertFalse(chain.isInstalled)
        XCTAssertNil(chain.previous)
        XCTAssertTrue(Self.isSame(try XCTUnwrap(slot.get()), Self.previousHandler))

        slot.refusesSet = false
        chain.install(RecordingCrashRecorder())

        XCTAssertTrue(chain.isInstalled)
        XCTAssertEqual(slot.setCount, 2)
        XCTAssertTrue(Self.isSame(try XCTUnwrap(chain.previous), Self.previousHandler))
        XCTAssertTrue(Self.isSame(try XCTUnwrap(slot.get()), Self.entryPoint))
    }

    func testTheEntryPointAlreadyInTheSlot_IsNotItsOwnPrevious() {
        let slot = FakeExceptionHandlerSlot(Self.entryPoint)
        let chain = ExceptionHandlerChain(slot: slot, entryPoint: Self.entryPoint)

        chain.install(RecordingCrashRecorder())

        XCTAssertTrue(chain.isInstalled)
        XCTAssertNil(chain.previous)
    }

    // MARK: - The process slot

    func testTheSystemSlot_SetsAndGetsTheProcessHandler() throws {
        let system = SystemExceptionHandlerSlot()
        let saved = system.get()
        defer { system.set(saved) }

        system.set(Self.previousHandler)

        XCTAssertTrue(Self.isSame(try XCTUnwrap(system.get()), Self.previousHandler))
    }

    // MARK: - Helpers

    private func makeChain(previous: Handler?) -> ExceptionHandlerChain {
        ExceptionHandlerChain(slot: FakeExceptionHandlerSlot(previous), entryPoint: Self.entryPoint)
    }

    private func loggingRecorder() -> RecordingCrashRecorder {
        RecordingCrashRecorder { ExceptionHandlerChainTests.log.append("recorded \($0.name.rawValue)") }
    }

    private func sample(_ name: String) -> NSException {
        NSException(name: NSExceptionName(name), reason: "test", userInfo: nil)
    }

    private static func isSame(_ lhs: Handler, _ rhs: Handler) -> Bool {
        unsafeBitCast(lhs, to: UnsafeRawPointer.self) == unsafeBitCast(rhs, to: UnsafeRawPointer.self)
    }
}
#endif
