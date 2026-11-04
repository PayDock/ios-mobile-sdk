//
//  TelemetryEffect.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// What the reducer asks the effect handler to do.
package enum TelemetryEffect: Sendable, Equatable {
    case enqueue(PendingRecord)
    /// Upsert by record id.
    case persist(PendingRecord)
    case scheduleFlush(delayMilliseconds: Int64)
    /// Drain up to `maxRecords` and export them.
    case export(maxRecords: Int)
    case drop(DropReason)

    package enum DropReason: Sendable, Equatable {
        case disabled, levelOff, levelFiltered
    }
}
