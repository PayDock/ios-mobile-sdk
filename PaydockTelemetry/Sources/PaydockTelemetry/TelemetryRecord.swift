//
//  TelemetryRecord.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// One telemetry record as it is encoded (spec § 5.2). Never carries message text.
package struct TelemetryRecord: Sendable, Equatable {
    package let id: String                   // log.record.uid
    package let timeUnixMillis: Int64        // UTC epoch ms; written as timeUnixNano = ms * 1_000_000
    package let severity: Severity
    package let body: String
    package let attributes: [TelemetryAttribute]   // in Allowlist.recordKeys order, each key at most once

    package init(id: String, timeUnixMillis: Int64, severity: Severity, body: String, attributes: [TelemetryAttribute]) {
        self.id = id
        self.timeUnixMillis = timeUnixMillis
        self.severity = severity
        self.body = body
        self.attributes = attributes
    }

    package func value(_ key: String) -> AttributeValue? {
        attributes.first { $0.key == key }?.value
    }

    /// The session.id string, if present.
    package var sessionId: String? { string("session.id") }

    /// The event.name string, if present.
    package var eventName: String? { string("event.name") }

    /// Replaces the key's value, or inserts it in `Allowlist.recordKeys` order; an unlisted key goes last.
    package func with(_ key: String, _ value: AttributeValue) -> TelemetryRecord {
        var updated = attributes
        let attribute = TelemetryAttribute(key: key, value: value)
        if let index = updated.firstIndex(where: { $0.key == key }) {
            updated[index] = attribute
        } else {
            let rank = Self.rank(key)
            let index = updated.firstIndex { Self.rank($0.key) > rank } ?? updated.endIndex
            updated.insert(attribute, at: index)
        }
        return TelemetryRecord(id: id, timeUnixMillis: timeUnixMillis, severity: severity, body: body, attributes: updated)
    }

    package func with(timeUnixMillis: Int64) -> TelemetryRecord {
        TelemetryRecord(id: id, timeUnixMillis: timeUnixMillis, severity: severity, body: body, attributes: attributes)
    }

    private func string(_ key: String) -> String? {
        if case let .string(text) = value(key) {
            return text
        }
        return nil
    }

    /// The key's position in `Allowlist.recordKeys`; an unlisted key ranks after every listed one.
    private static func rank(_ key: String) -> Int {
        Allowlist.recordKeys.firstIndex(of: key) ?? Allowlist.recordKeys.count
    }
}
