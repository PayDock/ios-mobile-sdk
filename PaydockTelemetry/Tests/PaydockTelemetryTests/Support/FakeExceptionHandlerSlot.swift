//
//  FakeExceptionHandlerSlot.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// A process slot of its own, so the chain is tested without touching the real one. It counts every set and, while
/// `refusesSet` is true, keeps its handler, as a slot another library holds would.
final class FakeExceptionHandlerSlot: ExceptionHandlerSlot, @unchecked Sendable {
    typealias Handler = @convention(c) (NSException) -> Void

    private let lock = NSLock()
    private var handler: Handler?
    private var sets = 0
    private var refusing = false

    init(_ handler: Handler? = nil) {
        self.handler = handler
    }

    var setCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return sets
    }

    var refusesSet: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return refusing
        }
        set {
            lock.lock()
            refusing = newValue
            lock.unlock()
        }
    }

    func get() -> Handler? {
        lock.lock()
        defer { lock.unlock() }
        return handler
    }

    func set(_ handler: Handler?) {
        lock.lock()
        defer { lock.unlock() }
        sets += 1
        if !refusing {
            self.handler = handler
        }
    }
}
