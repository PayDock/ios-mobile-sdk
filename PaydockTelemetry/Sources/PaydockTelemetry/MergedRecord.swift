//
//  MergedRecord.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The duplicate gate's output: the kept record and the ids of every record it stands for, its own included.
package struct MergedRecord: Sendable, Equatable {
    package let record: TelemetryRecord
    package let sourceIds: [String]

    package init(record: TelemetryRecord, sourceIds: [String]) {
        self.record = record
        self.sourceIds = sourceIds
    }
}
