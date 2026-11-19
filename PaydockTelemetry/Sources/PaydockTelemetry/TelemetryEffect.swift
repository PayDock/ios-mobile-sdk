//
//  TelemetryEffect.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// What the reducer asks the effect handler to do.
package enum TelemetryEffect: Sendable, Equatable {
    /// Build, filter, upsert by record id.
    case persist(PendingRecord)
    case scheduleFlush(delayMilliseconds: Int64)
    /// Flush everything pending, in batches of `maxRecords`.
    case export(maxRecords: Int)
    case drop(DropReason)

    package enum DropReason: Sendable, Equatable { case disabled, rateLimit, notReportable, alreadyOpened }
}
