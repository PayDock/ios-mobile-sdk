//
//  TelemetryReducerTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry
import XCTest

final class TelemetryReducerTests: XCTestCase {

    private typealias Limits = TelemetryLimits

    private static let start: Int64 = 1_700_000_000_000
    private static let scheduleFlush = TelemetryEffect.scheduleFlush(delayMilliseconds: TelemetryLimits.flushIntervalMilliseconds)
    private static let export = TelemetryEffect.export(maxRecords: TelemetryLimits.batchMaxRecords)

    private let initial = TelemetryState(level: .all, enabled: true, sessionId: "session")
    private var sequence = RecordSequence()

    // MARK: - Limits

    func testLimits_AreTheSpecParameters() {
        XCTAssertEqual(Limits.flushIntervalMilliseconds, 10_000)
        XCTAssertEqual(Limits.flushThreshold, 20)
        XCTAssertEqual(Limits.batchMaxRecords, 50)
        XCTAssertEqual(Limits.batchMaxBytes, 262_144)
        XCTAssertEqual(Limits.storeMaxRecords, 100)
        XCTAssertEqual(Limits.storeMaxBytes, 1_048_576)
        XCTAssertEqual(Limits.recordMaxAgeMilliseconds, 156 * 3_600_000)
        XCTAssertEqual(Limits.requestTimeoutSeconds, 15)
        XCTAssertEqual(Limits.retryMaxAttempts, 5)
        XCTAssertEqual(Limits.retryBaseDelayMilliseconds, 5_000)
        XCTAssertEqual(Limits.retryMaxDelayMilliseconds, 60_000)
        XCTAssertEqual(Limits.hourlyCap, 400)
        XCTAssertEqual(Limits.hourMilliseconds, 3_600_000)
    }

    // MARK: - Reported

    func testRecordIds_StartAtOne_FromTheInjectedSequence() {
        var state = initial
        var ids: [String] = []
        for index in 0..<3 {
            let result = reduce(state, .reported(TelemetryFixtures.crash()), now: Self.start + Int64(index))
            for case let .persist(record) in result.effects {
                ids.append(record.id)
                XCTAssertEqual(record.sessionId, "session")
                XCTAssertEqual(record.createdAt, Self.start + Int64(index))
            }
            state = result.state
        }

        XCTAssertEqual(ids, ["session-1", "session-2", "session-3"])
        XCTAssertEqual(sequence.next(), 4)
    }

    func testReported_Persists_RaisesTheCounts_AndArmsOneTimer() {
        let event = TelemetryFixtures.sdkError()

        let first = reduce(initial, .reported(event))

        XCTAssertEqual(first.effects, [.persist(pending(1, event)), Self.scheduleFlush])
        XCTAssertEqual(first.state.pending, 1)
        XCTAssertEqual(first.state.createdInWindow, 1)
        XCTAssertEqual(first.state.windowStart, 0)
        XCTAssertTrue(first.state.flushScheduled)

        let second = reduce(first.state, .reported(event))

        XCTAssertEqual(second.effects, [.persist(pending(2, event))])
        XCTAssertEqual(second.state.pending, 2)
        XCTAssertEqual(second.state.createdInWindow, 2)
    }

    func testEveryReportIsItsOwnRecord_NothingIsHeldOrCollapsed() {
        var state = initial
        var persisted: [PendingRecord] = []
        for _ in 0..<3 {
            let result = reduce(state, .reported(TelemetryFixtures.sdkError()))
            persisted += result.effects.compactMap { if case let .persist(record) = $0 { return record } else { return nil } }
            state = result.state
        }

        XCTAssertEqual(persisted.map(\.id), ["session-1", "session-2", "session-3"])
        XCTAssertEqual(state.pending, 3)
    }

    func testDropped_CannotBeReported_WhateverTheState() {
        var disabled = initial
        disabled.enabled = false
        for state in [initial, disabled] {
            let result = reduce(state, .reported(.dropped(reason: .rateLimit, count: 3)))

            XCTAssertEqual(result.state, state)
            XCTAssertEqual(result.effects, [.drop(.notReportable)])
        }
        XCTAssertEqual(sequence.next(), 1, "a refused report used a sequence number")
    }

    // MARK: - Enabled and level

    func testDisabled_DropsWithoutStateChange() {
        var state = initial
        state.enabled = false

        let result = reduce(state, .reported(TelemetryFixtures.crash()))

        XCTAssertEqual(result.state, state)
        XCTAssertEqual(result.effects, [.drop(.disabled)])
    }

    func testLevelOff_DropsWithoutStateChange() {
        var state = initial
        state.level = .off

        for event in everyKind() + [.widgetOpened(widget: "CardDetailsWidget")] {
            let result = reduce(state, .reported(event))

            XCTAssertEqual(result.state, state)
            XCTAssertEqual(result.effects, [.drop(.levelOff)])
        }
        XCTAssertEqual(sequence.next(), 1)
    }

    func testLevelErrors_KeepsEveryErrorKind_AndDropsWidgetOpened() {
        var state = initial
        state.level = .errors

        for event in everyKind() {
            XCTAssertTrue(TelemetryReducer.isError(event))
            XCTAssertEqual(reduce(state, .reported(event)).state.pending, 1)
        }
        let widget = TelemetryEvent.widgetOpened(widget: "CardDetailsWidget")
        let result = reduce(state, .reported(widget))

        XCTAssertFalse(TelemetryReducer.isError(widget))
        XCTAssertFalse(TelemetryReducer.isError(.dropped(reason: .tooOld, count: 1)))
        XCTAssertEqual(result.state, state)
        XCTAssertEqual(result.effects, [.drop(.levelFiltered)])
    }

    func testLevelAll_KeepsEveryReportableKind() {
        for event in everyKind() + [.widgetOpened(widget: "CardDetailsWidget")] {
            XCTAssertEqual(reduce(initial, .reported(event)).state.pending, 1)
        }
    }

    func testLevelChanged_SetsTheLevel_WithoutEffects() {
        for level in [TelemetryLevel.off, .errors, .all] {
            let result = reduce(initial, .levelChanged(level))

            var expected = initial
            expected.level = level
            XCTAssertEqual(result.state, expected)
            XCTAssertEqual(result.effects, [])
        }
        let off = reduce(initial, .levelChanged(.off)).state
        XCTAssertEqual(reduce(off, .reported(TelemetryFixtures.crash())).effects, [.drop(.levelOff)])
    }

    // MARK: - Flush and export

    func testOnlyATimerFlush_ClearsFlushScheduled() {
        var state = initial
        state.flushScheduled = true

        for source in [TelemetryIntent.FlushSource.start, .debugSend, .retry] {
            XCTAssertTrue(reduce(state, .flush(source)).state.flushScheduled, "\(source)")
        }
        XCTAssertTrue(reduce(state, .appBackgrounded).state.flushScheduled)
        XCTAssertFalse(reduce(state, .flush(.timer)).state.flushScheduled)
    }

    func testFlushAndBackground_ExportEvenAtZeroPending() {
        let intents: [TelemetryIntent] = [.flush(.timer), .flush(.start), .flush(.debugSend), .flush(.retry), .appBackgrounded]
        for intent in intents {
            let result = reduce(initial, intent, now: Self.start)

            XCTAssertEqual(result.effects, [Self.export], "\(intent)")
            XCTAssertEqual(result.state.lastExport, Self.start, "\(intent)")
        }
    }

    func testExport_ResetsPending_AndRecordsTheTime() {
        var state = initial
        state.pending = 7

        let result = reduce(state, .flush(.timer), now: Self.start + 5)

        XCTAssertEqual(result.effects, [Self.export])
        XCTAssertEqual(result.state.pending, 0)
        XCTAssertEqual(result.state.lastExport, Self.start + 5)
    }

    func testThreshold_TheTwentiethPendingRecordExports() {
        var state = initial
        for index in 1..<Limits.flushThreshold {
            let result = reduce(state, .reported(TelemetryFixtures.crash()))
            XCTAssertFalse(result.effects.contains(Self.export), "exported at \(index)")
            state = result.state
        }
        XCTAssertEqual(state.pending, 19)

        let result = reduce(state, .reported(TelemetryFixtures.crash()), now: Self.start + 100)

        XCTAssertEqual(result.effects, [.persist(pending(20, TelemetryFixtures.crash(), at: Self.start + 100)), Self.export])
        XCTAssertEqual(result.state.pending, 0)
        XCTAssertEqual(result.state.createdInWindow, 20)
        XCTAssertEqual(result.state.lastExport, Self.start + 100)
    }

    func testPendingCounted_SetsPending_AndArmsTheTimerWhenRecordsWait() {
        let counted = reduce(initial, .pendingCounted(3))

        XCTAssertEqual(counted.state.pending, 3)
        XCTAssertEqual(counted.effects, [Self.scheduleFlush])
        XCTAssertTrue(counted.state.flushScheduled)
        XCTAssertEqual(reduce(counted.state, .pendingCounted(5)).effects, [], "a second timer")

        let empty = reduce(initial, .pendingCounted(0))
        XCTAssertEqual(empty.state.pending, 0)
        XCTAssertEqual(empty.effects, [])
        XCTAssertFalse(empty.state.flushScheduled)
    }

    func testAfterExportStopped_NoExportAndNoTimer_EvenAtTwenty() {
        let stopped = reduce(initial, .exportStopped).state
        XCTAssertTrue(stopped.exportStopped)

        var state = stopped
        for _ in 0..<Limits.flushThreshold {
            let result = reduce(state, .reported(TelemetryFixtures.crash()))
            XCTAssertEqual(result.effects.count, 1)
            state = result.state
        }
        XCTAssertEqual(state.pending, 20)
        XCTAssertFalse(state.flushScheduled)
        for intent in [TelemetryIntent.flush(.timer), .flush(.start), .appBackgrounded, .pendingCounted(30),
                       .recordsDropped(reason: .storeFull, count: 2)] {
            let effects = reduce(state, intent).effects
            XCTAssertFalse(effects.contains(Self.export), "\(intent)")
            XCTAssertFalse(effects.contains(Self.scheduleFlush), "\(intent)")
        }
        XCTAssertNil(reduce(state, .flush(.timer)).state.lastExport)
    }

    // MARK: - Hourly cap

    func testThe401stRecordInAnHour_IsDropped_AndTheHoursNoticeCountsEveryDropInOneRecord() {
        var state = initial
        for index in 0..<Limits.hourlyCap {
            state = reduce(state, .reported(TelemetryFixtures.crash()), elapsed: Int64(index)).state
        }
        XCTAssertEqual(state.createdInWindow, 400)
        XCTAssertTrue(state.flushScheduled)

        let first = reduce(state, .reported(TelemetryFixtures.crash()), now: Self.start + 1, elapsed: 1_000)
        let notice = PendingRecord(id: "session-401", sessionId: "session", event: .dropped(reason: .rateLimit, count: 1),
                                   createdAt: Self.start + 1)
        XCTAssertEqual(first.effects, [.drop(.rateLimit), .persist(notice)])
        XCTAssertEqual(first.state.createdInWindow, 400)
        XCTAssertEqual(first.state.notices[.rateLimit], DroppedNotice(id: "session-401", count: 1, createdAt: Self.start + 1))

        var later = first.state
        for count in 2...4 {
            let result = reduce(later, .reported(TelemetryFixtures.sdkError()), now: Self.start + Int64(count), elapsed: 2_000)
            let updated = PendingRecord(id: "session-401", sessionId: "session",
                                        event: .dropped(reason: .rateLimit, count: count), createdAt: Self.start + 1)
            XCTAssertEqual(result.effects, [.drop(.rateLimit), .persist(updated)])
            later = result.state
        }
        XCTAssertEqual(later.notices[.rateLimit]?.count, 4)
        XCTAssertEqual(later.createdInWindow, 400)
        XCTAssertEqual(sequence.next(), 402, "a later drop used a sequence number")
    }

    func testTheHourRollsOnElapsedAlone_SoAWallClockJumpChangesNothing() {
        var state = initial
        for _ in 0..<Limits.hourlyCap {
            state = reduce(state, .reported(TelemetryFixtures.crash()), elapsed: 0).state
        }

        let jumpedAhead = reduce(state, .reported(TelemetryFixtures.crash()), now: Self.start + 2 * Limits.hourMilliseconds,
                                 elapsed: Limits.hourMilliseconds - 1)
        XCTAssertEqual(jumpedAhead.effects.first, .drop(.rateLimit))
        let jumpedBack = reduce(jumpedAhead.state, .reported(TelemetryFixtures.crash()),
                                now: Self.start - Limits.hourMilliseconds, elapsed: Limits.hourMilliseconds - 1)
        XCTAssertEqual(jumpedBack.effects.first, .drop(.rateLimit))

        let rolled = reduce(jumpedBack.state, .reported(TelemetryFixtures.crash()), now: Self.start,
                            elapsed: Limits.hourMilliseconds)
        guard case let .persist(record) = rolled.effects.first else {
            return XCTFail("the next hour did not create a record: \(rolled.effects)")
        }
        XCTAssertEqual(record.event, TelemetryFixtures.crash())
        XCTAssertEqual(rolled.state.windowStart, Limits.hourMilliseconds)
        XCTAssertEqual(rolled.state.createdInWindow, 1)
        XCTAssertEqual(rolled.state.notices, [:])
    }

    // MARK: - Dropped notices

    func testRecordsDropped_CreatesTheNotice_ThenUpdatesIt_AndNoticesSkipTheCap() {
        let created = reduce(initial, .recordsDropped(reason: .storeFull, count: 3), now: Self.start)
        let notice = PendingRecord(id: "session-1", sessionId: "session", event: .dropped(reason: .storeFull, count: 3),
                                   createdAt: Self.start)

        XCTAssertEqual(created.effects, [.persist(notice), Self.scheduleFlush])
        XCTAssertEqual(created.state.pending, 1)
        XCTAssertEqual(created.state.createdInWindow, 0)
        XCTAssertEqual(created.state.notices, [.storeFull: DroppedNotice(id: "session-1", count: 3, createdAt: Self.start)])

        let updated = reduce(created.state, .recordsDropped(reason: .storeFull, count: 2), now: Self.start + 9)
        let updatedNotice = PendingRecord(id: "session-1", sessionId: "session", event: .dropped(reason: .storeFull, count: 5),
                                          createdAt: Self.start)

        XCTAssertEqual(updated.effects, [.persist(updatedNotice)])
        XCTAssertEqual(updated.state.pending, 2)
        XCTAssertEqual(updated.state.notices[.storeFull], DroppedNotice(id: "session-1", count: 5, createdAt: Self.start))

        var full = initial
        full.windowStart = 0
        full.createdInWindow = Limits.hourlyCap
        let atTheCap = reduce(full, .recordsDropped(reason: .tooOld, count: 1))
        XCTAssertEqual(atTheCap.effects.first, .persist(PendingRecord(id: "session-2", sessionId: "session",
                                                                      event: .dropped(reason: .tooOld, count: 1),
                                                                      createdAt: Self.start)))
        XCTAssertEqual(atTheCap.state.createdInWindow, Limits.hourlyCap)
    }

    func testRecordsDropped_OneNoticePerReason() {
        var state = initial
        let reasons: [TelemetryEvent.DroppedReason] = [.rateLimit, .storeFull, .tooOld, .rejected]
        for reason in reasons + reasons {
            state = reduce(state, .recordsDropped(reason: reason, count: 1)).state
        }

        XCTAssertEqual(state.notices.count, 4)
        XCTAssertEqual(Set(state.notices.values.map(\.id)), ["session-1", "session-2", "session-3", "session-4"])
        XCTAssertTrue(state.notices.values.allSatisfy { $0.count == 2 })
    }

    func testRecordsDropped_IsIgnored_ForZeroDisabledAndOff() {
        var disabled = initial
        disabled.enabled = false
        var off = initial
        off.level = .off
        let cases: [(TelemetryState, Int)] = [(initial, 0), (initial, -1), (disabled, 3), (off, 3)]

        for (state, count) in cases {
            let result = reduce(state, .recordsDropped(reason: .rejected, count: count))

            XCTAssertEqual(result.state, state)
            XCTAssertEqual(result.effects, [])
        }
        var errors = initial
        errors.level = .errors
        XCTAssertEqual(reduce(errors, .recordsDropped(reason: .rejected, count: 1)).state.notices.count, 1)
    }

    func testAfterNoticesExported_TheNextDropStartsANewNotice_WithANewIdAndOnlyTheNewCount() {
        let first = reduce(initial, .recordsDropped(reason: .rejected, count: 3)).state
        let unrelated = reduce(first, .noticesExported(["session-9"]))
        XCTAssertEqual(unrelated.state, first)
        XCTAssertEqual(unrelated.effects, [])

        let exported = reduce(first, .noticesExported(["session-1"])).state
        XCTAssertEqual(exported.notices, [:])

        let next = reduce(exported, .recordsDropped(reason: .rejected, count: 2), now: Self.start + 7)
        let notice = PendingRecord(id: "session-2", sessionId: "session", event: .dropped(reason: .rejected, count: 2),
                                   createdAt: Self.start + 7)
        XCTAssertEqual(next.effects.first, .persist(notice))
        XCTAssertEqual(next.state.notices[.rejected], DroppedNotice(id: "session-2", count: 2, createdAt: Self.start + 7))
    }

    // MARK: - Determinism

    func testReduce_IsDeterministic_WithTwoFreshSequences() {
        let intents: [TelemetryIntent] = everyKind().map { .reported($0) } + [
            .recordsDropped(reason: .storeFull, count: 2), .flush(.start), .pendingCounted(4), .appBackgrounded,
            .noticesExported(["session-5"]), .levelChanged(.errors), .reported(.widgetOpened(widget: "CardDetailsWidget")),
            .flush(.timer), .exportStopped, .reported(TelemetryFixtures.crash())
        ]
        let first = run(intents, sequence: RecordSequence())
        let second = run(intents, sequence: RecordSequence())

        XCTAssertEqual(first.states, second.states)
        XCTAssertEqual(first.effects, second.effects)
    }

    // MARK: - Helpers

    private func reduce(_ state: TelemetryState, _ intent: TelemetryIntent, now: Int64 = TelemetryReducerTests.start, elapsed: Int64 = 0)
        -> (state: TelemetryState, effects: [TelemetryEffect]) {
        TelemetryReducer.reduce(state, intent, now: now, elapsed: elapsed, sequence: sequence)
    }

    private func run(_ intents: [TelemetryIntent], sequence: RecordSequence)
        -> (states: [TelemetryState], effects: [[TelemetryEffect]]) {
        var state = initial
        var states: [TelemetryState] = []
        var effects: [[TelemetryEffect]] = []
        for (index, intent) in intents.enumerated() {
            let result = TelemetryReducer.reduce(state, intent, now: Self.start + Int64(index), elapsed: Int64(index) * 1_000,
                                                 sequence: sequence)
            state = result.state
            states.append(state)
            effects.append(result.effects)
        }
        return (states, effects)
    }

    private func pending(_ sequence: Int, _ event: TelemetryEvent, at createdAt: Int64 = TelemetryReducerTests.start) -> PendingRecord {
        PendingRecord(id: "session-\(sequence)", sessionId: "session", event: event, createdAt: createdAt)
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
