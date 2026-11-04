//
//  SequentialIdGenerator.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// `"<prefix>-0"`, `"<prefix>-1"`, …
final class SequentialIdGenerator: IdGenerator, @unchecked Sendable {
    private let lock = NSLock()
    private let prefix: String
    private var next = 0

    init(prefix: String = "id") {
        self.prefix = prefix
    }

    func newId() -> String {
        lock.lock()
        defer { lock.unlock() }
        let id = "\(prefix)-\(next)"
        next += 1
        return id
    }
}
