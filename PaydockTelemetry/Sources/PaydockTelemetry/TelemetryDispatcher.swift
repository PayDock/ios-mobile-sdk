//
//  TelemetryDispatcher.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// One serial background queue. Never blocks the caller.
package protocol TelemetryDispatcher: Sendable {
    /// False when the task was dropped.
    @discardableResult func post(_ task: @escaping @Sendable () -> Void) -> Bool
    /// False when the task was dropped.
    @discardableResult func postDelayed(milliseconds: Int64, _ task: @escaping @Sendable () -> Void) -> Bool
}
