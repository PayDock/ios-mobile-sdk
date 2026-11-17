//
//  RecordingAppLifecycle.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Counts every registration and keeps the last callback, so a test sends the app to the background by hand.
final class RecordingAppLifecycle: AppLifecycle, @unchecked Sendable {
    private let lock = NSLock()
    private var registrations = 0
    private var callback: (@Sendable (_ finished: @escaping @Sendable () -> Void) -> Void)?

    var registerCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return registrations
    }

    func register(onBackground: @escaping @Sendable (_ finished: @escaping @Sendable () -> Void) -> Void) {
        lock.lock()
        registrations += 1
        callback = onBackground
        lock.unlock()
    }

    /// Calls the registered callback, as the app's move to the background would; false when nothing is registered.
    @discardableResult
    func enterBackground(finished: @escaping @Sendable () -> Void) -> Bool {
        lock.lock()
        let current = callback
        lock.unlock()
        guard let current else {
            return false
        }
        current(finished)
        return true
    }
}
