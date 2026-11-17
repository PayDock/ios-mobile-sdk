//
//  TelemetryEffectHandler.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The only place with I/O. Runs each effect on its own, in order, and returns the follow-up intents, in order, the
/// sent notices first (see `run`):
///
/// - `.persist`: builds the record with the monitor's connection type and filters it. A filtered record without
///   `session.id` or `log.record.uid` is not saved (`.recordsDropped(.rejected, 1)`, or nothing for a dropped notice,
///   so a notice never counts itself); otherwise it is saved, the store
///   is pruned, and each non-zero prune count follows (`.storeFull`, `.tooOld`).
/// - `.export`: one flush of the runner; then `.exportStopped` when it stopped, `.pendingCounted`, `.noticesExported`
///   when any, and each non-zero count (`.tooOld`, `.storeFull`, `.rejected`).
/// - `.scheduleFlush`: the closure. `.drop`: nothing.
package final class TelemetryEffectHandler: @unchecked Sendable {
    private let store: any DurableStore
    private let runner: ExportRunner
    private let deviceContext: any DeviceContextProvider
    private let connection: any ConnectionMonitor
    private let clock: any Clock
    private let scheduleFlush: @Sendable (Int64) -> Void

    package init(store: any DurableStore, runner: ExportRunner, deviceContext: any DeviceContextProvider,
                 connection: any ConnectionMonitor, clock: any Clock,
                 scheduleFlush: @escaping @Sendable (Int64) -> Void) {
        self.store = store
        self.runner = runner
        self.deviceContext = deviceContext
        self.connection = connection
        self.clock = clock
        self.scheduleFlush = scheduleFlush
    }

    /// The follow-ups, in order, except that every `.noticesExported` goes first: a notice the export just sent leaves
    /// the state before any drop counted in the same run, so that drop starts a new notice instead of updating, and
    /// re-sending, the sent one (R_09). Telemetry queue only.
    package func run(_ effects: [TelemetryEffect]) -> [TelemetryIntent] {
        let followUps = effects.flatMap(run)
        return followUps.filter(Self.isNoticesExported) + followUps.filter { !Self.isNoticesExported($0) }
    }

    private static func isNoticesExported(_ intent: TelemetryIntent) -> Bool {
        if case .noticesExported = intent {
            return true
        }
        return false
    }

    private func run(_ effect: TelemetryEffect) -> [TelemetryIntent] {
        switch effect {
        case let .persist(pending):
            return persist(pending)
        case let .export(maxRecords):
            return export(maxRecords: maxRecords)
        case let .scheduleFlush(delayMilliseconds):
            scheduleFlush(delayMilliseconds)
            return []
        case .drop:
            return []
        }
    }

    private func persist(_ pending: PendingRecord) -> [TelemetryIntent] {
        let record = Allowlist.filter(RecordFactory.create(pending, connection: connection.current()))
        guard record.value("session.id") != nil, record.value("log.record.uid") != nil else {
            // A rejected dropped notice is not counted again: counting it would create another notice, rejected the
            // same way, without end.
            if case .dropped = pending.event {
                return []
            }
            return [.recordsDropped(reason: .rejected, count: 1)]
        }
        store.save(record)
        let pruned = store.prune(now: clock.now())
        return Self.dropped([(.storeFull, pruned.storeFull), (.tooOld, pruned.tooOld)])
    }

    private func export(maxRecords: Int) -> [TelemetryIntent] {
        let report = runner.flush(now: clock.now(), maxRecords: maxRecords)
        var followUps: [TelemetryIntent] = []
        if report.stopped {
            followUps.append(.exportStopped)
        }
        followUps.append(.pendingCounted(report.pending))
        if !report.exportedNoticeIds.isEmpty {
            followUps.append(.noticesExported(report.exportedNoticeIds))
        }
        return followUps + Self.dropped([(.tooOld, report.tooOld), (.storeFull, report.storeFull),
                                         (.rejected, report.rejected)])
    }

    /// A `.recordsDropped` for each non-zero count, in order.
    private static func dropped(_ counts: [(TelemetryEvent.DroppedReason, Int)]) -> [TelemetryIntent] {
        counts.filter { $0.1 > 0 }.map { .recordsDropped(reason: $0.0, count: $0.1) }
    }
}
