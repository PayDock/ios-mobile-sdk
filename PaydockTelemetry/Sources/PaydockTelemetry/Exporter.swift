//
//  Exporter.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Sends a batch: one attempt; never throws.
package protocol Exporter: Sendable {
    func export(_ batch: ExportBatch) -> ExportResult
}
