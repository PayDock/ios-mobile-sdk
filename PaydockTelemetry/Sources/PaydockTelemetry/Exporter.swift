//
//  Exporter.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Sends a batch.
package protocol Exporter: Sendable {
    func export(_ batch: ExportBatch) -> ExportResult
}
