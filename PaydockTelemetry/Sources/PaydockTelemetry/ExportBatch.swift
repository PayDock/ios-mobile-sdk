//
//  ExportBatch.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// What the exporter sends: the device context (with app.installation.id) and filtered, stamped records that each
/// carry session.id and log.record.uid.
package struct ExportBatch: Sendable, Equatable {
    package let resource: ResourceAttributes
    package let records: [TelemetryRecord]

    package init(resource: ResourceAttributes, records: [TelemetryRecord]) {
        self.resource = resource
        self.records = records
    }
}
