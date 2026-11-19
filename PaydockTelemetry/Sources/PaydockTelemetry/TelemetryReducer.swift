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
        case let .recordsDropped(reason, count):
            guard count > 0, next.enabled else {
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

    // MARK: - Intents

    /// The first matching rule: not reportable, disabled, a widget already opened this session; a payment finished
    /// without an open attempt, or else its record with the measured duration and no cap check; otherwise the hourly
    /// cap, or a new record (a widget opened is remembered, a payment started is opened), the threshold export and the
    /// timer.
    private static func reported(_ event: TelemetryEvent, _ state: inout TelemetryState, now: Int64, elapsed: Int64,
                                 sequence: RecordSequence) -> [TelemetryEffect] {
        if case .dropped = event {
            return [.drop(.notReportable)]
        }
        guard state.enabled else {
            return [.drop(.disabled)]
        }
        if case let .widgetOpened(widget) = event, state.openedWidgets.contains(widget) {
            return [.drop(.alreadyOpened)]
        }
        if case let .paymentFinished(widget, paymentId, outcome, errorCode, _) = event {
            guard let index = state.openPayments.firstIndex(where: { $0.id == paymentId }) else {
                return [.drop(.paymentNotOpen)]
            }
            let attempt = state.openPayments.remove(at: index)
            roll(&state, elapsed: elapsed)
            let finished = TelemetryEvent.paymentFinished(widget: widget, paymentId: paymentId, outcome: outcome,
                                                          errorCode: errorCode, durationMs: max(0, elapsed - attempt.startedAt))
            return created(finished, &state, now: now, sequence: sequence)
        }

        roll(&state, elapsed: elapsed)
        if state.createdInWindow >= Limits.hourlyCap {
            return [.drop(.rateLimit)] + notice(.rateLimit, 1, &state, now: now, sequence: sequence) + schedule(&state)
        }
        if case let .widgetOpened(widget) = event {
            state.openedWidgets.insert(widget)
        }
        if case let .paymentStarted(_, paymentId) = event {
            state.openPayments.append(TelemetryState.OpenPayment(id: paymentId, startedAt: elapsed))
            if state.openPayments.count > Limits.maxOpenPayments {
                state.openPayments.removeFirst(state.openPayments.count - Limits.maxOpenPayments)
            }
        }
        return created(event, &state, now: now, sequence: sequence)
    }

    /// A new record: persisted, counted in `pending` and the hour, then the threshold export and the timer.
    private static func created(_ event: TelemetryEvent, _ state: inout TelemetryState, now: Int64,
                                sequence: RecordSequence) -> [TelemetryEffect] {
        let record = PendingRecord(id: newId(state, sequence), sessionId: state.sessionId, event: event, createdAt: now)
        var effects: [TelemetryEffect] = [.persist(record)]
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
