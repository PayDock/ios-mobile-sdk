//
//  LockHolder.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Holds a lock on a thread of its own, as another thread of the app would, until released: an `NSLock` must be
/// unlocked by the thread that locked it.
final class LockHolder: @unchecked Sendable {
    private let held = DispatchSemaphore(value: 0)
    private let releasing = DispatchSemaphore(value: 0)
    private let released = DispatchSemaphore(value: 0)

    /// Returns once the lock is held.
    func hold(_ lock: NSLock) {
        let thread = Thread { [held, releasing, released] in
            lock.lock()
            held.signal()
            releasing.wait()
            lock.unlock()
            released.signal()
        }
        thread.start()
        held.wait()
    }

    /// Returns once the lock is released.
    func release() {
        releasing.signal()
        released.wait()
    }
}
