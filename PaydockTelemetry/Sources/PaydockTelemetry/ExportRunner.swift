//
//  ExportRunner.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The only sender (R_11–R_13). A flush prunes the store, reads the oldest records, merges their duplicates, stamps
/// them at send, checks every batch with the allowlist and exports the batches in turn under the retry rules. A file
/// is removed only after `.success`, `.rejected` or a single-record `.tooLarge`. Runs on the telemetry queue only.
package final class ExportRunner: @unchecked Sendable {
    private static let noticeName = "paydock.telemetry.dropped"

    private let store: any DurableStore
    private let exporter: any Exporter
    private let deviceContext: any DeviceContextProvider
    private let clockOffset: ClockOffset
    private let monotonic: any MonotonicClock
    private let retryPolicy: RetryPolicy
    private let scheduleRetry: @Sendable (Int64) -> Void

    /// 401/403 or give-up: nothing more is sent this process.
    private var stopped = false
    private var failedAttempts = 0
    /// Monotonic milliseconds before which a flush sends nothing.
    private var nextAttemptAt: Int64?

    package init(store: any DurableStore, exporter: any Exporter, deviceContext: any DeviceContextProvider,
                 clockOffset: ClockOffset, monotonic: any MonotonicClock, retryPolicy: RetryPolicy,
                 scheduleRetry: @escaping @Sendable (Int64) -> Void) {
        self.store = store
        self.exporter = exporter
        self.deviceContext = deviceContext
        self.clockOffset = clockOffset
        self.monotonic = monotonic
        self.retryPolicy = retryPolicy
        self.scheduleRetry = scheduleRetry
    }

    /// `now`: UTC epoch milliseconds, the flush's send time. Never throws.
    package func flush(now: Int64, maxRecords: Int) -> FlushReport {
        if stopped || nextAttemptAt.map({ monotonic.elapsed() < $0 }) == true {
            return FlushReport(pending: store.count())
        }
        let pruned = store.prune(now: now)
        var report = FlushReport(tooOld: pruned.tooOld, storeFull: pruned.storeFull, pending: 0)
        let resource = deviceContext.current()
        if Allowlist.violations(resource: resource, records: []).isEmpty {
            send(resource: resource, now: now, maxRecords: max(1, maxRecords), report: &report)
        }
        report.pending = store.count()
        return report
    }

    // MARK: - Sending

    private func send(resource: ResourceAttributes, now: Int64, maxRecords: Int, report: inout FlushReport) {
        let merged = DuplicateGate.merge(store.oldest(max: TelemetryLimits.storeMaxRecords))
        var complete: [MergedRecord] = []
        for item in merged {
            if item.record.value("session.id") == nil || item.record.value("log.record.uid") == nil {
                discard([item], report: &report)
            } else {
                complete.append(item)
            }
        }
        let offset = clockOffset.milliseconds
        let stamped = complete.map { item in
            MergedRecord(record: SendStamp.stamp(item.record, sentAt: now, clockOffsetMilliseconds: offset),
                         sourceIds: item.sourceIds)
        }
        var queue = batches(stamped, resource: resource, maxRecords: maxRecords)
        while !queue.isEmpty {
            let batch = checked(queue.removeFirst(), resource: resource, report: &report)
            guard !batch.isEmpty else {
                continue
            }
            switch exporter.export(ExportBatch(resource: resource, records: batch.map(\.record))) {
            case let .success(rejectedRecords):
                accept(batch, rejectedRecords: rejectedRecords, report: &report)
            case .tooLarge where batch.count == 1, .rejected:
                discard(batch, report: &report)
            case .tooLarge:
                let half = batch.count / 2
                queue.insert(contentsOf: [Array(batch[..<half]), Array(batch[half...])], at: 0)
            case .unauthorized:
                stop(&report)
                return
            case let .retry(retryAfterMilliseconds):
                retryLater(retryAfterMilliseconds: retryAfterMilliseconds, report: &report)
                return
            }
        }
    }

    /// Oldest first: at most `maxRecords` records and `batchMaxBytes` of JSON each (the envelope plus each record's
    /// `recordJSON` size, measured once); a single larger record goes alone.
    private func batches(_ records: [MergedRecord], resource: ResourceAttributes, maxRecords: Int) -> [[MergedRecord]] {
        let envelope = OtlpLogEncoder.encode(resource: resource, records: []).count
        var result: [[MergedRecord]] = []
        var current: [MergedRecord] = []
        var size = envelope
        for item in records {
            let bytes = OtlpLogEncoder.recordJSON(item.record).count
            if !current.isEmpty, current.count >= maxRecords || size + bytes > TelemetryLimits.batchMaxBytes {
                result.append(current)
                current = []
                size = envelope
            }
            current.append(item)
            size += bytes
        }
        if !current.isEmpty {
            result.append(current)
        }
        return result
    }

    /// The batch without the records that fail the allowlist's batch check; those are removed and counted rejected.
    private func checked(_ batch: [MergedRecord], resource: ResourceAttributes,
                         report: inout FlushReport) -> [MergedRecord] {
        guard !Allowlist.violations(resource: resource, records: batch.map(\.record)).isEmpty else {
            return batch
        }
        var kept: [MergedRecord] = []
        for item in batch {
            if Allowlist.violations(resource: resource, records: [item.record]).isEmpty {
                kept.append(item)
            } else {
                discard([item], report: &report)
            }
        }
        return kept
    }

    // MARK: - Outcomes

    private func accept(_ batch: [MergedRecord], rejectedRecords: Int64, report: inout FlushReport) {
        let sourceIds = batch.flatMap(\.sourceIds)
        store.remove(ids: sourceIds)
        failedAttempts = 0
        report.rejected += Int(min(max(0, rejectedRecords), Int64(Self.recordSourceCount(batch))))
        noteNotices(batch, report: &report)
    }

    /// Removes the records' sources from the store and counts them rejected; dropped notices are removed but never
    /// counted, so a lost notice does not create a notice about itself.
    private func discard(_ batch: [MergedRecord], report: inout FlushReport) {
        let sourceIds = batch.flatMap(\.sourceIds)
        store.remove(ids: sourceIds)
        report.rejected += Self.recordSourceCount(batch)
        noteNotices(batch, report: &report)
    }

    /// The sources of the batch's records, dropped notices excluded.
    private static func recordSourceCount(_ batch: [MergedRecord]) -> Int {
        batch.filter { $0.record.eventName != noticeName }.reduce(0) { $0 + $1.sourceIds.count }
    }

    private func noteNotices(_ batch: [MergedRecord], report: inout FlushReport) {
        for item in batch where item.record.eventName == Self.noticeName {
            report.exportedNoticeIds.formUnion(item.sourceIds)
        }
    }

    private func retryLater(retryAfterMilliseconds: Int64?, report: inout FlushReport) {
        failedAttempts += 1
        guard failedAttempts < TelemetryLimits.retryMaxAttempts else {
            stop(&report)
            return
        }
        let delay = retryPolicy.delayMilliseconds(failedAttempts: failedAttempts,
                                                  retryAfterMilliseconds: retryAfterMilliseconds)
        let (attemptAt, overflow) = monotonic.elapsed().addingReportingOverflow(delay)
        nextAttemptAt = overflow ? Int64.max : attemptAt
        scheduleRetry(delay)
    }

    private func stop(_ report: inout FlushReport) {
        stopped = true
        report.stopped = true
    }
}
