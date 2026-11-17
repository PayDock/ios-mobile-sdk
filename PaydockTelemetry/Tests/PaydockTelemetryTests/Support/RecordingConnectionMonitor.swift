//
//  RecordingConnectionMonitor.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Counts every start and answers with a type a test sets.
final class RecordingConnectionMonitor: ConnectionMonitor, @unchecked Sendable {
    private let lock = NSLock()
    private var starts = 0
    private var type: NetworkConnectionType

    init(_ type: NetworkConnectionType = .unknown) {
        self.type = type
    }

    var startCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return starts
    }

    var connectionType: NetworkConnectionType {
        get {
            lock.lock()
            defer { lock.unlock() }
            return type
        }
        set {
            lock.lock()
            type = newValue
            lock.unlock()
        }
    }

    func start() {
        lock.lock()
        starts += 1
        lock.unlock()
    }

    func current() -> NetworkConnectionType {
        connectionType
    }
}
