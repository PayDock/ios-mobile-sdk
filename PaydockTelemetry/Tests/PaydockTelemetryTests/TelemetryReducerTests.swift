//
//  TelemetryReducerTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

final class TelemetryReducerTests: XCTestCase {

    private typealias Reducer = TelemetryReducer

    private static let start: Int64 = 1_700_000_000_000
    private static let window = TelemetryReducer.collapseWindowMilliseconds
    private static let scheduleFlush = TelemetryEffect.scheduleFlush(delayMilliseconds: TelemetryReducer.flushIntervalMilliseconds)
    private static let export = TelemetryEffect.export(maxRecords: TelemetryReducer.maxBatch)

    private let initial = TelemetryState(level: .all, enabled: true, sessionId: "session")

    // MARK: - Constants

    func testConstants() {
        XCTAssertEqual(Reducer.flushIntervalMilliseconds, 10_000)
        XCTAssertEqual(Reducer.flushThreshold, 20)
        XCTAssertEqual(Reducer.maxBatch, 50)
        XCTAssertEqual(Reducer.collapseWindowMilliseconds, 60_000)
    }

    // MARK: - Enabled and level

    func testDisabled_DropsWithoutStateChange() {
        var state = initial
        state.enabled = false

        let result = Reducer.reduce(state, .reported(TelemetryFixtures.crash()), now: Self.start)

        XCTAssertEqual(result.state, state)
        XCTAssertEqual(result.effects, [.drop(.disabled)])
    }

    func testLevelOff_DropsWithoutStateChange() {
        var state = initial
        state.level = .off

        for event in everyKind() {
            let result = Reducer.reduce(state, .reported(event), now: Self.start)

            XCTAssertEqual(result.state, state)
            XCTAssertEqual(result.effects, [.drop(.levelOff)])
        }
    }

    func testLevelErrors_KeepsEveryKindToday() {
        var state = initial
        state.level = .errors

        for event in everyKind() {
            XCTAssertTrue(Reducer.isError(event))
            let result = Reducer.reduce(state, .reported(event), now: Self.start)

            XCTAssertEqual(result.state.persisted, 1)
            XCTAssertFalse(result.effects.contains { if case .drop = $0 { return true } else { return false } })
        }
    }

    func testLevelAll_KeepsEveryKind() {
        for event in everyKind() {
            let result = Reducer.reduce(initial, .reported(event), now: Self.start)

            XCTAssertEqual(result.state.persisted, 1)
            XCTAssertEqual(result.state.nextSequence, 1)
        }
    }

    func testLevelChanged_SetsTheLevel_WithoutEffects() {
        for level in [TelemetryLevel.off, .errors, .all] {
            let result = Reducer.reduce(initial, .levelChanged(level), now: Self.start)

            var expected = initial
            expected.level = level
            XCTAssertEqual(result.state, expected)
            XCTAssertEqual(result.effects, [])
        }
    }

    func testLevelChangedToOff_ThenReported_Drops() {
        let off = Reducer.reduce(initial, .levelChanged(.off), now: Self.start).state

        XCTAssertEqual(Reducer.reduce(off, .reported(TelemetryFixtures.crash()), now: Self.start).effects, [.drop(.levelOff)])
    }

    // MARK: - Crash

    func testCrash_IsNeverHeld() {
        let event = TelemetryFixtures.crash()
        let record = PendingRecord(id: "session-0", sessionId: "session", event: event, firstSeenAt: Self.start)

        let first = Reducer.reduce(initial, .reported(event), now: Self.start)

        XCTAssertEqual(first.effects, [.persist(record), .enqueue(record), Self.scheduleFlush])
        XCTAssertEqual(first.state.queued, 1)
        XCTAssertEqual(first.state.persisted, 1)
        XCTAssertTrue(first.state.collapsing.isEmpty)
        XCTAssertTrue(first.state.flushScheduled)

        let second = Reducer.reduce(first.state, .reported(event), now: Self.start + 1)
        let secondRecord = PendingRecord(id: "session-1", sessionId: "session", event: event, firstSeenAt: Self.start + 1)

        XCTAssertEqual(second.effects, [.persist(secondRecord), .enqueue(secondRecord)])
        XCTAssertEqual(second.state.queued, 2)
    }

    // MARK: - Collapse

    func testError_IsHeld_PersistedOnFirstSight_AndSchedulesAFlush() {
        let event = TelemetryFixtures.sdkError()
        let record = PendingRecord(id: "session-0", sessionId: "session", event: event, firstSeenAt: Self.start)

        let result = Reducer.reduce(initial, .reported(event), now: Self.start)

        XCTAssertEqual(result.effects, [.persist(record), Self.scheduleFlush])
        XCTAssertEqual(result.state.collapsing, [Reducer.fingerprint(event): record])
        XCTAssertEqual(result.state.queued, 0)
        XCTAssertEqual(result.state.persisted, 1)
        XCTAssertTrue(result.state.flushScheduled)
    }

    func testError_RepeatedWithinTheWindow_IsCounted_WithoutEffects() {
        let event = TelemetryFixtures.sdkError()
        let held = Reducer.reduce(initial, .reported(event), now: Self.start).state

        let result = Reducer.reduce(held, .reported(event), now: Self.start + Self.window - 1)

        XCTAssertEqual(result.effects, [])
        XCTAssertEqual(result.state.collapsing[Reducer.fingerprint(event)]?.occurrences, 2)
        XCTAssertEqual(result.state.collapsing[Reducer.fingerprint(event)]?.firstSeenAt, Self.start)
        XCTAssertEqual(result.state.persisted, 1)
        XCTAssertEqual(result.state.queued, 0)
    }

    func testError_RepeatedAfterTheWindow_ReleasesTheHeldRecord_AndHoldsTheNewOne() throws {
        let event = TelemetryFixtures.sdkError()
        let key = Reducer.fingerprint(event)
        let first = Reducer.reduce(initial, .reported(event), now: Self.start).state
        let counted = Reducer.reduce(first, .reported(event), now: Self.start + 1).state
        var released = try XCTUnwrap(counted.collapsing[key])
        released.occurrences = 2

        let result = Reducer.reduce(counted, .reported(event), now: Self.start + Self.window)

        let fresh = PendingRecord(id: "session-2", sessionId: "session", event: event, firstSeenAt: Self.start + Self.window)
        XCTAssertEqual(result.effects, [.enqueue(released), .persist(released), .persist(fresh)])
        XCTAssertEqual(result.state.collapsing, [key: fresh])
        XCTAssertEqual(result.state.queued, 1)
        XCTAssertEqual(result.state.persisted, 2)
    }

    func testReleasedRecordSeenOnce_IsEnqueuedWithoutPersistingAgain() {
        let event = TelemetryFixtures.sdkError()
        let held = Reducer.reduce(initial, .reported(event), now: Self.start)
        let record = PendingRecord(id: "session-0", sessionId: "session", event: event, firstSeenAt: Self.start)

        let result = Reducer.reduce(held.state, .flush, now: Self.start + Self.window)

        XCTAssertEqual(result.effects, [.enqueue(record), Self.export])
    }

    func testDifferentErrors_AreHeldApart() {
        let first = Reducer.reduce(initial, .reported(TelemetryFixtures.sdkError("Sample.One")), now: Self.start).state
        let second = Reducer.reduce(first, .reported(TelemetryFixtures.sdkError("Sample.Two")), now: Self.start)

        XCTAssertEqual(second.state.collapsing.count, 2)
        XCTAssertEqual(second.state.persisted, 2)
    }

    func testUncaughtException_AndSdkError_ShareTheErrorName() {
        let info = TelemetryFixtures.info()

        XCTAssertEqual(Reducer.fingerprint(.uncaughtException(error: info)), Reducer.fingerprint(.sdkError(error: info)))
        XCTAssertEqual(Reducer.fingerprint(.sdkError(error: info)), "paydock.error|Sample.Error|")
    }

    // MARK: - Fingerprint

    func testFingerprint_Crash() {
        XCTAssertEqual(Reducer.fingerprint(TelemetryFixtures.crash()), "paydock.crash|NSException|")
        XCTAssertEqual(Reducer.fingerprint(.crash(error: nil, source: .metricKit)), "paydock.crash||")
    }

    func testFingerprint_TopPaydockFrame_IsTheFirstFrameNamingAModuleAsAWholeWord() {
        let frames = [
            "0   libsystem_kernel.dylib   0x0000000100000000 __pthread_kill + 8",
            "1   Sample   0x0000000100000010 $s9MobileSDK6SampleV + 12",
            "2   MobileSDKExtra   0x0000000100000020 sample + 4",
            "3   DataVault   0x0000000100000030 vault + 4",
            "4   MobileSDK   0x0000000100000040 sample + 8"
        ]

        XCTAssertEqual(
            Reducer.fingerprint(TelemetryFixtures.sdkError(frames: frames)),
            "paydock.error|Sample.Error|3   DataVault   0x0000000100000030 vault + 4"
        )
    }

    func testFingerprint_EveryPaydockModuleCounts() {
        for module in Reducer.paydockModules {
            let frame = "0   \(module)   0x0000000100000000 sample + 4"

            XCTAssertEqual(Reducer.fingerprint(TelemetryFixtures.sdkError(frames: [frame])), "paydock.error|Sample.Error|\(frame)")
        }
    }

    func testFingerprint_NetworkFailure_IsKeyedByMethodTemplateAndFailure() {
        let frame = "0   MobileSDK   0x0000000100000000 sample + 4"
        let transportError = TelemetryFixtures.info("Foundation.URLError", frames: [frame])

        XCTAssertEqual(
            Reducer.fingerprint(TelemetryFixtures.networkFailure()),
            "paydock.network.failure|||POST|/v1/charges/{id}|http_503"
        )
        XCTAssertEqual(
            Reducer.fingerprint(TelemetryFixtures.networkFailure(method: .get, failure: .transport(kind: .timeout, error: transportError))),
            "paydock.network.failure|Foundation.URLError|\(frame)|GET|/v1/charges/{id}|transport_timeout"
        )
        XCTAssertEqual(
            Reducer.fingerprint(TelemetryFixtures.networkFailure(method: .delete, urlTemplate: "/v1/vault/{id}", failure: .decode())),
            "paydock.network.failure|||DELETE|/v1/vault/{id}|decode"
        )
    }

    func testFingerprint_NetworkFailure_MethodNamesAndTransportKinds() {
        let methods: [(TelemetryEvent.HTTPMethod, String)] = [
            (.get, "GET"), (.post, "POST"), (.put, "PUT"), (.patch, "PATCH"), (.delete, "DELETE"), (.head, "HEAD"),
            (.options, "OPTIONS")
        ]
        for (method, name) in methods {
            let fingerprint = Reducer.fingerprint(TelemetryFixtures.networkFailure(method: method))
            XCTAssertTrue(fingerprint.hasSuffix("|\(name)|/v1/charges/{id}|http_503"), fingerprint)
        }
        let kinds: [(TelemetryEvent.TransportKind, String)] = [
            (.timeout, "timeout"), (.connection, "connection"), (.tls, "tls"), (.unknown, "unknown")
        ]
        for (kind, name) in kinds {
            let fingerprint = Reducer.fingerprint(TelemetryFixtures.networkFailure(failure: .transport(kind: kind)))
            XCTAssertTrue(fingerprint.hasSuffix("|transport_\(name)"), fingerprint)
        }
    }

    func testNetworkFailures_DifferingInMethodTemplateOrFailure_AreHeldApart() {
        let events = [
            TelemetryFixtures.networkFailure(),
            TelemetryFixtures.networkFailure(method: .get),
            TelemetryFixtures.networkFailure(urlTemplate: "/v1/vault/{id}"),
            TelemetryFixtures.networkFailure(failure: .httpStatus(code: 500)),
            TelemetryFixtures.networkFailure(failure: .transport(kind: .tls))
        ]

        var state = initial
        for event in events {
            state = Reducer.reduce(state, .reported(event), now: Self.start).state
        }
        state = Reducer.reduce(state, .reported(TelemetryFixtures.networkFailure()), now: Self.start + 1).state

        XCTAssertEqual(state.collapsing.count, events.count)
        XCTAssertEqual(state.collapsing[Reducer.fingerprint(TelemetryFixtures.networkFailure())]?.occurrences, 2)
    }

    // MARK: - Flush

    func testFlush_ReleasesOnlyExpiredRecords_InFingerprintOrder_ExportsAndReschedules() {
        var state = initial
        state = Reducer.reduce(state, .reported(TelemetryFixtures.sdkError("Sample.B")), now: Self.start).state
        state = Reducer.reduce(state, .reported(TelemetryFixtures.sdkError("Sample.A")), now: Self.start).state
        state = Reducer.reduce(state, .reported(TelemetryFixtures.sdkError("Sample.C")), now: Self.start + 10).state
        let recordB = record(0, TelemetryFixtures.sdkError("Sample.B"), at: Self.start)
        let recordA = record(1, TelemetryFixtures.sdkError("Sample.A"), at: Self.start)

        let result = Reducer.reduce(state, .flush, now: Self.start + Self.window)

        XCTAssertEqual(result.effects, [.enqueue(recordA), .enqueue(recordB), Self.export, Self.scheduleFlush])
        XCTAssertEqual(result.state.collapsing.count, 1)
        XCTAssertEqual(result.state.queued, 0)
        XCTAssertEqual(result.state.lastExport, Self.start + Self.window)
        XCTAssertTrue(result.state.flushScheduled)
    }

    func testFlush_ExportsInBatchesOf50() {
        var state = initial
        state.queued = 120
        state.flushScheduled = true

        let result = Reducer.reduce(state, .flush, now: Self.start)

        XCTAssertEqual(result.effects, [Self.export, Self.export, Self.export])
        XCTAssertEqual(result.state.queued, 0)
        XCTAssertEqual(result.state.lastExport, Self.start)
        XCTAssertFalse(result.state.flushScheduled)
    }

    func testFlush_WithNothingToDo_ClearsTheScheduleOnly() {
        var state = initial
        state.flushScheduled = true

        let result = Reducer.reduce(state, .flush, now: Self.start)

        XCTAssertEqual(result.effects, [])
        XCTAssertNil(result.state.lastExport)
        XCTAssertFalse(result.state.flushScheduled)
    }

    func testFlush_WithAHeldRecordInItsWindow_Reschedules() {
        let state = Reducer.reduce(initial, .reported(TelemetryFixtures.sdkError()), now: Self.start).state

        let result = Reducer.reduce(state, .flush, now: Self.start + TelemetryReducer.flushIntervalMilliseconds)

        XCTAssertEqual(result.effects, [Self.scheduleFlush])
        XCTAssertNil(result.state.lastExport)
        XCTAssertTrue(result.state.flushScheduled)
    }

    // MARK: - Threshold

    func testThreshold_TheTwentiethQueuedRecordExports() {
        var state = initial
        for index in 0..<(TelemetryReducer.flushThreshold - 1) {
            let result = Reducer.reduce(state, .reported(TelemetryFixtures.crash()), now: Self.start + Int64(index))
            XCTAssertFalse(result.effects.contains(Self.export), "exported at \(index + 1)")
            state = result.state
        }
        XCTAssertEqual(state.queued, 19)

        let result = Reducer.reduce(state, .reported(TelemetryFixtures.crash()), now: Self.start + 100)
        let record = PendingRecord(id: "session-19", sessionId: "session", event: TelemetryFixtures.crash(), firstSeenAt: Self.start + 100)

        XCTAssertEqual(result.effects, [.persist(record), .enqueue(record), Self.export])
        XCTAssertEqual(result.state.queued, 0)
        XCTAssertEqual(result.state.lastExport, Self.start + 100)
    }

    func testThreshold_AboveTheBatch_KeepsTheRemainder_AndSchedules() {
        var state = initial
        state.queued = 69

        let result = Reducer.reduce(state, .reported(TelemetryFixtures.crash()), now: Self.start)

        XCTAssertEqual(result.state.queued, 20)
        XCTAssertEqual(Array(result.effects.suffix(2)), [Self.export, Self.scheduleFlush])
        XCTAssertTrue(result.state.flushScheduled)
    }

    // MARK: - App backgrounded

    func testAppBackgrounded_ReleasesEverything_ExportsAndDoesNotReschedule() {
        var state = initial
        state = Reducer.reduce(state, .reported(TelemetryFixtures.sdkError("Sample.B")), now: Self.start).state
        state = Reducer.reduce(state, .reported(TelemetryFixtures.sdkError("Sample.A")), now: Self.start).state
        state = Reducer.reduce(state, .reported(TelemetryFixtures.crash()), now: Self.start).state
        let recordB = record(0, TelemetryFixtures.sdkError("Sample.B"), at: Self.start)
        let recordA = record(1, TelemetryFixtures.sdkError("Sample.A"), at: Self.start)

        let result = Reducer.reduce(state, .appBackgrounded, now: Self.start + 1)

        XCTAssertEqual(result.effects, [.enqueue(recordA), .enqueue(recordB), Self.export])
        XCTAssertTrue(result.state.collapsing.isEmpty)
        XCTAssertEqual(result.state.queued, 0)
        XCTAssertEqual(result.state.lastExport, Self.start + 1)
        XCTAssertEqual(result.state.flushScheduled, state.flushScheduled)
    }

    func testAppBackgrounded_WithNothingHeld_HasNoEffect() {
        let result = Reducer.reduce(initial, .appBackgrounded, now: Self.start)

        XCTAssertEqual(result.state, initial)
        XCTAssertEqual(result.effects, [])
    }

    // MARK: - Identity

    func testRecordIds_FollowTheSessionAndTheSequence() {
        var state = TelemetryState(level: .all, enabled: true, sessionId: "abc")
        var ids: [String] = []
        for index in 0..<3 {
            let result = Reducer.reduce(state, .reported(TelemetryFixtures.crash()), now: Self.start + Int64(index))
            for case let .enqueue(record) in result.effects {
                ids.append(record.id)
                XCTAssertEqual(record.sessionId, "abc")
            }
            state = result.state
        }

        XCTAssertEqual(ids, ["abc-0", "abc-1", "abc-2"])
        XCTAssertEqual(state.nextSequence, 3)
    }

    func testDroppedEvents_DoNotUseASequenceNumber() {
        var state = initial
        state.level = .off

        XCTAssertEqual(Reducer.reduce(state, .reported(TelemetryFixtures.crash()), now: Self.start).state.nextSequence, 0)
    }

    // MARK: - Purity

    func testReduce_IsPure() {
        let inputs: [TelemetryIntent] = everyKind().map { .reported($0) } + [.flush, .appBackgrounded, .levelChanged(.errors)]
        var state = initial
        for (index, intent) in inputs.enumerated() {
            let now = Self.start + Int64(index) * Self.window
            let first = Reducer.reduce(state, intent, now: now)
            let second = Reducer.reduce(state, intent, now: now)

            XCTAssertEqual(first.state, second.state)
            XCTAssertEqual(first.effects, second.effects)
            state = first.state
        }
    }

    // MARK: - Helpers

    private func record(_ sequence: Int, _ event: TelemetryEvent, at firstSeenAt: Int64) -> PendingRecord {
        PendingRecord(id: "session-\(sequence)", sessionId: "session", event: event, firstSeenAt: firstSeenAt)
    }

    private func everyKind() -> [TelemetryEvent] {
        [
            TelemetryFixtures.crash(),
            .uncaughtException(error: TelemetryFixtures.info()),
            TelemetryFixtures.sdkError(),
            TelemetryFixtures.networkFailure()
        ]
    }
}
