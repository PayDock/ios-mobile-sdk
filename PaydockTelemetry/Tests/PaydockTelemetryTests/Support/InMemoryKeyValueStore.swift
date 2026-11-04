//
//  InMemoryKeyValueStore.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// A dictionary behind a lock that counts reads and writes. Share one instance to model a relaunch on the same
/// install; a new instance is a fresh install.
final class InMemoryKeyValueStore: KeyValueStore, @unchecked Sendable {
    private let lock = NSLock()
    private var values: [String: String]
    private var reads = 0
    private var writes = 0

    init(_ values: [String: String] = [:]) {
        self.values = values
    }

    var readCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return reads
    }

    var writeCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return writes
    }

    var contents: [String: String] {
        lock.lock()
        defer { lock.unlock() }
        return values
    }

    func string(forKey key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        reads += 1
        return values[key]
    }

    func set(_ value: String, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        writes += 1
        values[key] = value
    }
}
