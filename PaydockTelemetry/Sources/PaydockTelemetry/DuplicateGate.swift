//
//  DuplicateGate.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Merges records with the same session, event name and signature (R_07, spec § 6.1). Pure.
package enum DuplicateGate {
    private static let occurrencesKey = "paydock.occurrences"
    private static let attemptKey = "paydock.http.attempt"
    /// Never merged: a notice, and the payment records (each attempt is its own).
    private static let unmergedNames: Set<String> = [
        "paydock.telemetry.dropped", "paydock.payment.started", "paydock.payment.finished"
    ]

    private static let commonKeys = ["exception.type", "exception.stacktrace", "paydock.widget"]
    private static let keysByEvent: [String: [String]] = [
        "paydock.crash": commonKeys + ["paydock.crash.kind", "paydock.crash.source", "paydock.crash.reason"],
        "paydock.error": commonKeys + ["paydock.error.kind", "paydock.error.code"],
        "paydock.widget.opened": ["paydock.widget"],
        "paydock.network.failure": commonKeys + [
            "http.request.method", "url.template", "http.response.status_code", "error.type", "paydock.api.error.code",
            "paydock.api.error.summary_code", "paydock.api.gateway.codes"
        ]
    ]

    /// One entry per group, in input order by each group's first record. The kept record is the group's earliest, by
    /// time then the id's sequence as a number, with its own id; a group of more than one carries the summed
    /// `paydock.occurrences` (an absent one counts as 1) and the highest `paydock.http.attempt`. A single record is kept
    /// unchanged.
    package static func merge(_ records: [TelemetryRecord]) -> [MergedRecord] {
        var groups: [[TelemetryRecord]] = []
        var groupIndex: [String: Int] = [:]
        for record in records {
            guard let signature = signature(record) else {
                groups.append([record])
                continue
            }
            if let index = groupIndex[signature] {
                groups[index].append(record)
            } else {
                groupIndex[signature] = groups.count
                groups.append([record])
            }
        }
        return groups.map(mergeGroup)
    }

    /// `"<session.id>\0<event.name>"`, then `"\0<key>=<value>"` for each signature key present, in order; nil for a
    /// notice, a payment record or a record without `session.id`, which are never merged.
    package static func signature(_ record: TelemetryRecord) -> String? {
        guard let sessionId = record.sessionId, !unmergedNames.contains(record.eventName ?? "") else {
            return nil
        }
        let name = record.eventName ?? ""
        var signature = "\(sessionId)\u{0}\(name)"
        for key in keysByEvent[name] ?? commonKeys {
            if let value = record.value(key) {
                signature += "\u{0}\(key)=\(text(value))"
            }
        }
        return signature
    }

    // MARK: - Helpers

    private static func mergeGroup(_ group: [TelemetryRecord]) -> MergedRecord {
        guard group.count > 1, var kept = group.min(by: isEarlier) else {
            return MergedRecord(record: group[0], sourceIds: group.map(\.id))
        }
        let occurrences = group.reduce(Int64(0)) { sum, record in sum + (int(record.value(occurrencesKey)) ?? 1) }
        if occurrences > 1 {
            kept = kept.with(occurrencesKey, .int(occurrences))
        }
        if let attempt = group.compactMap({ int($0.value(attemptKey)) }).max() {
            kept = kept.with(attemptKey, .int(attempt))
        }
        return MergedRecord(record: kept, sourceIds: group.map(\.id))
    }

    private static func isEarlier(_ lhs: TelemetryRecord, _ rhs: TelemetryRecord) -> Bool {
        if lhs.timeUnixMillis != rhs.timeUnixMillis {
            return lhs.timeUnixMillis < rhs.timeUnixMillis
        }
        let lhsSequence = sequence(of: lhs.id)
        let rhsSequence = sequence(of: rhs.id)
        return lhsSequence != rhsSequence ? lhsSequence < rhsSequence : lhs.id < rhs.id
    }

    /// The number after the id's last `-`; an id without one sorts last.
    private static func sequence(of id: String) -> Int64 {
        id.split(separator: "-").last.flatMap { Int64($0) } ?? Int64.max
    }

    private static func int(_ value: AttributeValue?) -> Int64? {
        if case let .int(number) = value {
            return number
        }
        return nil
    }

    private static func text(_ value: AttributeValue) -> String {
        switch value {
        case let .string(text): return text
        case let .int(number): return String(number)
        case let .bool(flag): return flag ? "true" : "false"
        }
    }
}
