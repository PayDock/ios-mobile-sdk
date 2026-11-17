//
//  TemporaryDirectory.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import XCTest

/// A fresh, empty directory under the system's temporary directory; `remove()` deletes it, after each test.
final class TemporaryDirectory: @unchecked Sendable {
    let url: URL

    init() throws {
        url = FileManager.default.temporaryDirectory
            .appendingPathComponent("PaydockTelemetryTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    /// A path inside the directory that does not exist yet.
    func child(_ name: String) -> URL {
        url.appendingPathComponent(name, isDirectory: true)
    }

    func remove() {
        try? FileManager.default.removeItem(at: url)
    }
}
