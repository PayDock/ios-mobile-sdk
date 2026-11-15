//
//  SendStamp.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// D20, spec § 5.2, § 6: the late-record rule applied at send time; mirrors stamp() of the fixtures' generate.py.
package enum SendStamp {
    package static let orderingWindowMilliseconds: Int64 = 1_800_000
    package static let occurredAtKey = "paydock.occurred_at"

    /// occurred = record time + offset, sent = sentAt + offset. When sent - occurred > the window: time = sent and
    /// paydock.occurred_at = UtcTimestamp.iso8601(occurred), inserted with `with`; otherwise time = occurred. Body unchanged.
    package static func stamp(_ record: TelemetryRecord, sentAt: Int64, clockOffsetMilliseconds: Int64) -> TelemetryRecord {
        let occurred = record.timeUnixMillis + clockOffsetMilliseconds
        let sent = sentAt + clockOffsetMilliseconds
        guard sent - occurred > orderingWindowMilliseconds else {
            return record.with(timeUnixMillis: occurred)
        }
        return record.with(timeUnixMillis: sent).with(occurredAtKey, .string(UtcTimestamp.iso8601(occurred)))
    }
}
