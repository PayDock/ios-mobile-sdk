//
//  ImmediateDispatcher.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Runs `post` inline on the caller's thread. Records each `postDelayed` delay and keeps its task until
/// `runDelayed()`, so a test drives scheduled flushes by hand.
final class ImmediateDispatcher: TelemetryDispatcher, @unchecked Sendable {
    private let lock = NSLock()
    private var delays: [Int64] = []
    private var delayedTasks: [@Sendable () -> Void] = []

    var delayedMilliseconds: [Int64] {
        lock.lock()
        defer { lock.unlock() }
        return delays
    }

    @discardableResult
    func post(_ task: @escaping @Sendable () -> Void) -> Bool {
        task()
        return true
    }

    @discardableResult
    func postDelayed(milliseconds: Int64, _ task: @escaping @Sendable () -> Void) -> Bool {
        lock.lock()
        delays.append(milliseconds)
        delayedTasks.append(task)
        lock.unlock()
        return true
    }

    /// Runs the delayed tasks posted so far, in order; tasks they post wait for the next call.
    func runDelayed() {
        lock.lock()
        let tasks = delayedTasks
        delayedTasks = []
        lock.unlock()
        tasks.forEach { $0() }
    }
}
