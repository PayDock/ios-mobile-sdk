//
//  ScriptedExporter.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Records every batch and answers with its scripted results in order, then with `fallback`.
final class ScriptedExporter: Exporter, @unchecked Sendable {
    private let lock = NSLock()
    private var script: [ExportResult]
    private let fallback: ExportResult
    private var batchLog: [ExportBatch] = []

    init(_ script: [ExportResult] = [], fallback: ExportResult = .success(rejectedRecords: 0)) {
        self.script = script
        self.fallback = fallback
    }

    var batches: [ExportBatch] {
        lock.lock()
        defer { lock.unlock() }
        return batchLog
    }

    /// The record ids of each batch, in order.
    var batchIds: [[String]] {
        batches.map { $0.records.map(\.id) }
    }

    func export(_ batch: ExportBatch) -> ExportResult {
        lock.lock()
        defer { lock.unlock() }
        batchLog.append(batch)
        return script.isEmpty ? fallback : script.removeFirst()
    }
}
