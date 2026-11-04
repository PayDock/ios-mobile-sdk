//
//  RecordingExporter.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// Records every batch and answers with a fixed result.
final class RecordingExporter: Exporter, @unchecked Sendable {
    private let lock = NSLock()
    private let result: ExportResult
    private var batchLog: [ExportBatch] = []

    init(result: ExportResult = .success) {
        self.result = result
    }

    var batches: [ExportBatch] {
        lock.lock()
        defer { lock.unlock() }
        return batchLog
    }

    func export(_ batch: ExportBatch) -> ExportResult {
        lock.lock()
        batchLog.append(batch)
        lock.unlock()
        return result
    }
}
