//
//  Clock.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The current time as UTC epoch milliseconds. Injected so the reducer's caller stays testable.
package protocol Clock: Sendable {
    func now() -> Int64
}
