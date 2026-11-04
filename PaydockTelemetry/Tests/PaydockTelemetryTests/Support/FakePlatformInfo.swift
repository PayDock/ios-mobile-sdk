//
//  FakePlatformInfo.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Synthetic platform values that count how often each one is read.
final class FakePlatformInfo: PlatformInfo, @unchecked Sendable {
    private let lock = NSLock()
    private var counts: [String: Int] = [:]

    var readCounts: [String: Int] {
        lock.lock()
        defer { lock.unlock() }
        return counts
    }

    var osVersion: String { read("osVersion", "17.4.1") }
    var modelIdentifier: String { read("modelIdentifier", "iPhone15,2") }
    var appId: String { read("appId", "com.paydock.sample") }
    var appVersion: String { read("appVersion", "2.3.0") }
    var appDebuggable: Bool { read("appDebuggable", true) }

    private func read<Value>(_ name: String, _ value: Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        counts[name, default: 0] += 1
        return value
    }
}
