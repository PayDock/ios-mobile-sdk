//
//  TelemetryReducer.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Pure apart from the session's record sequence: no I/O, no clock, no randomness. The same state, intent, times and
/// sequence give the same output. A new ID is always `"<sessionId>-<sequence.next()>"`.
package enum TelemetryReducer {
    private typealias Limits = TelemetryLimits

    /// `now`: UTC epoch milliseconds; `elapsed`: monotonic milliseconds, which alone roll the hour.
    package static func reduce(_ state: TelemetryState, _ intent: TelemetryIntent, now: Int64, elapsed: Int64,
                               sequence: RecordSequence) -> (state: TelemetryState, effects: [TelemetryEffect]) {
        var next = state
        var effects: [TelemetryEffect] = []
        switch intent {
        case let .reported(event):
            effects = reported(event, &next, now: now, elapsed: elapsed, sequence: sequence)
        case let .flush(source):
            if source == .timer {
                next.flushScheduled = false
            }
            effects = export(&next, now: now)
        case .appBackgrounded:
            effects = export(&next, now: now)
        case let .levelChanged(level):
            next.level = level
        case let .recordsDropped(reason, count):
            guard count > 0, next.enabled, next.level != .off else {
                return (state, [])
            }
            roll(&next, elapsed: elapsed)
            effects = notice(reason, count, &next, now: now, sequence: sequence)
            effects += schedule(&next)
        case let .pendingCounted(count):
            next.pending = count
            effects = schedule(&next)
        case let .noticesExported(ids):
            next.notices = next.notices.filter { !ids.contains($0.value.id) }
        case .exportStopped:
            next.exportStopped = true
        }
        return (next, effects)
    }

    /// True for the four error kinds; a widget opened and a dropped notice are not errors, so level `errors` drops them.
    package static func isError(_ event: TelemetryEvent) -> Bool {
        switch event {
        case .crash, .uncaughtException, .sdkError, .networkFailure:
            return true
        case .widgetOpened, .dropped:
            return false
        }
    }

    // MARK: - Intents

    /// The first matching rule: not reportable, disabled, off, filtered by the level, a widget already opened this
    /// session; otherwise the hourly cap, or a new record (a widget opened is remembered), the threshold export and the
    /// timer.
    private static func reported(_ event: TelemetryEvent, _ state: inout TelemetryState, now: Int64, elapsed: Int64,
                                 sequence: RecordSequence) -> [TelemetryEffect] {
        if case .dropped = event {
            return [.drop(.notReportable)]
        }
        guard state.enabled else {
            return [.drop(.disabled)]
        }
        if state.level == .off {
            return [.drop(.levelOff)]
        }
        if state.level == .errors && !isError(event) {
            return [.drop(.levelFiltered)]
        }
        if case let .widgetOpened(widget) = event, state.openedWidgets.contains(widget) {
            return [.drop(.alreadyOpened)]
        }

        roll(&state, elapsed: elapsed)
        if state.createdInWindow >= Limits.hourlyCap {
            return [.drop(.rateLimit)] + notice(.rateLimit, 1, &state, now: now, sequence: sequence) + schedule(&state)
        }
        let record = PendingRecord(id: newId(state, sequence), sessionId: state.sessionId, event: event, createdAt: now)
        var effects: [TelemetryEffect] = [.persist(record)]
        if case let .widgetOpened(widget) = event {
            state.openedWidgets.insert(widget)
        }
        state.pending += 1
        state.createdInWindow += 1
        if state.pending >= Limits.flushThreshold {
            effects += export(&state, now: now)
        }
        return effects + schedule(&state)
    }

    // MARK: - Rules

    /// Starts a new hour when none has started or a full hour has elapsed.
    private static func roll(_ state: inout TelemetryState, elapsed: Int64) {
        if let windowStart = state.windowStart, elapsed - windowStart < Limits.hourMilliseconds {
            return
        }
        state.windowStart = elapsed
        state.createdInWindow = 0
        state.notices = [:]
    }

    /// Updates the reason's unsent notice in place, or creates one with a new ID. Never counts toward the cap.
    private static func notice(_ reason: TelemetryEvent.DroppedReason, _ count: Int, _ state: inout TelemetryState,
                               now: Int64, sequence: RecordSequence) -> [TelemetryEffect] {
        let notice: DroppedNotice
        if let existing = state.notices[reason] {
            notice = DroppedNotice(id: existing.id, count: existing.count + count, createdAt: existing.createdAt)
        } else {
            notice = DroppedNotice(id: newId(state, sequence), count: count, createdAt: now)
        }
        state.notices[reason] = notice
        state.pending += 1
        let record = PendingRecord(id: notice.id, sessionId: state.sessionId,
                                   event: .dropped(reason: reason, count: notice.count), createdAt: notice.createdAt)
        return [.persist(record)]
    }

    /// Exports everything pending unless sending has stopped.
    private static func export(_ state: inout TelemetryState, now: Int64) -> [TelemetryEffect] {
        guard !state.exportStopped else {
            return []
        }
        state.pending = 0
        state.lastExport = now
        return [.export(maxRecords: Limits.batchMaxRecords)]
    }

    /// Arms the timer when records are pending, none is armed and sending has not stopped.
    private static func schedule(_ state: inout TelemetryState) -> [TelemetryEffect] {
        guard state.pending > 0, !state.flushScheduled, !state.exportStopped else {
            return []
        }
        state.flushScheduled = true
        return [.scheduleFlush(delayMilliseconds: Limits.flushIntervalMilliseconds)]
    }

    private static func newId(_ state: TelemetryState, _ sequence: RecordSequence) -> String {
        "\(state.sessionId)-\(sequence.next())"
    }
}
