//
//  NoOpRecordQueue.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Holds nothing: offer does nothing, drain gives nothing, size is 0.
package struct NoOpRecordQueue: RecordQueue {
    package init() {}
    package func offer(_ record: PendingRecord) {}
    package func drain(max: Int) -> [PendingRecord] { [] }
    package func size() -> Int { 0 }
}
