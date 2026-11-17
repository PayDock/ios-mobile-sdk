//
//  ReportOnce.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

/// Remembers which failures were reported, so one that repeats without a new cause (a SwiftUI initialiser run on every
/// redraw, a search completer failing on every keystroke) is reported once, not once per repeat. Keeps only the keys'
/// hash values, never the keys. Thread-safe.
final class ReportOnce: @unchecked Sendable {
    private let lock = NSLock()
    private var claimed: Set<Int> = []

    init() {}

    /// True the first time `key` is claimed, false after.
    func claim(_ key: AnyHashable) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return claimed.insert(key.hashValue).inserted
    }
}
