//
//  QueueingDispatcher.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Only queues: `post` and `postDelayed` keep their tasks until `runQueued()`, so a test sees that a caller returned
/// before the reducer ran.
final class QueueingDispatcher: TelemetryDispatcher, @unchecked Sendable {
    private let lock = NSLock()
    private var tasks: [@Sendable () -> Void] = []

    var queuedCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return tasks.count
    }

    @discardableResult
    func post(_ task: @escaping @Sendable () -> Void) -> Bool {
        lock.lock()
        tasks.append(task)
        lock.unlock()
        return true
    }

    @discardableResult
    func postDelayed(milliseconds: Int64, _ task: @escaping @Sendable () -> Void) -> Bool {
        post(task)
    }

    /// Runs the tasks queued so far, in order; tasks they queue wait for the next call.
    func runQueued() {
        lock.lock()
        let queued = tasks
        tasks = []
        lock.unlock()
        queued.forEach { $0() }
    }
}
