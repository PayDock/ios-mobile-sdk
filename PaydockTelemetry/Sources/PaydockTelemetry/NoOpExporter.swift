//
//  NoOpExporter.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Sends nothing and reports success.
package struct NoOpExporter: Exporter {
    package init() {}
    package func export(_ batch: ExportBatch) -> ExportResult { .success }
}
