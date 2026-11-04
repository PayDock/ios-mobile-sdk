//
//  RecordQueue.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Records waiting for export.
package protocol RecordQueue: Sendable {
    func offer(_ record: PendingRecord)
    func drain(max: Int) -> [PendingRecord]
    func size() -> Int
}
