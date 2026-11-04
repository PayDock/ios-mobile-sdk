//
//  ExportBatch.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// What the exporter sends: the device context (with app.installation.id) and records that each carry session.id.
package struct ExportBatch: Sendable, Equatable {
    package let resource: ResourceAttributes
    package let records: [PendingRecord]

    package init(resource: ResourceAttributes, records: [PendingRecord]) {
        self.resource = resource
        self.records = records
    }
}
