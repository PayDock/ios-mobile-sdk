//
//  SerialTelemetryDispatcher.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

#if DEBUG
import Foundation

/// One serial utility queue with a capacity: a task posted while `capacity` tasks are pending is dropped, never
/// waited for. Nothing waits on the caller's thread beyond the lock around one integer.
package final class SerialTelemetryDispatcher: TelemetryDispatcher, @unchecked Sendable {
    package static let defaultCapacity = 1_000
    package static let label = "com.paydock.telemetry"

    private let capacity: Int
    private let queue: DispatchQueue
    private let lock = NSLock()
    private var pending = 0

    package init(capacity: Int = SerialTelemetryDispatcher.defaultCapacity) {
        self.capacity = capacity
        self.queue = DispatchQueue(label: Self.label, qos: .utility)
    }

    @discardableResult
    package func post(_ task: @escaping @Sendable () -> Void) -> Bool {
        guard reserve() else {
            return false
        }
        queue.async {
            task()
            self.finish()
        }
        return true
    }

    @discardableResult
    package func postDelayed(milliseconds: Int64, _ task: @escaping @Sendable () -> Void) -> Bool {
        guard reserve() else {
            return false
        }
        queue.asyncAfter(deadline: .now() + .milliseconds(Int(milliseconds))) {
            task()
            self.finish()
        }
        return true
    }

    private func reserve() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard pending < capacity else {
            return false
        }
        pending += 1
        return true
    }

    private func finish() {
        lock.lock()
        defer { lock.unlock() }
        pending -= 1
    }
}
#endif
