//
//  AppLifecycle.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The app's move to the background, for the background flush (R_10, R_14).
package protocol AppLifecycle: Sendable {
    /// Called once, by the active runtime's start. `onBackground` gets a `finished` closure to call when the flush ends.
    func register(onBackground: @escaping @Sendable (_ finished: @escaping @Sendable () -> Void) -> Void)
}
