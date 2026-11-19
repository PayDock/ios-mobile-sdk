//
//  TelemetryIntent.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The reducer's single input. Only the target creates signals; the facade accepts events, never intents.
package enum TelemetryIntent: Sendable, Equatable {
    case reported(TelemetryEvent)
    case flush(FlushSource)
    case appBackgrounded
    case recordsDropped(reason: TelemetryEvent.DroppedReason, count: Int)
    case pendingCounted(Int)
    case noticesExported(Set<String>)
    case exportStopped

    package enum FlushSource: Sendable, Equatable { case timer, start, retry }
}
