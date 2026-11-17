//
//  FlushReport.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// What one flush did, for the handler's follow-up intents.
package struct FlushReport: Sendable, Equatable {
    package var tooOld = 0
    package var storeFull = 0
    package var rejected = 0
    /// The store's count after the flush.
    package var pending: Int
    /// This flush stopped sending (401/403 or give-up).
    package var stopped = false
    /// Notices whose batch was accepted or rejected.
    package var exportedNoticeIds: Set<String> = []

    package init(tooOld: Int = 0, storeFull: Int = 0, rejected: Int = 0, pending: Int, stopped: Bool = false,
                 exportedNoticeIds: Set<String> = []) {
        self.tooOld = tooOld
        self.storeFull = storeFull
        self.rejected = rejected
        self.pending = pending
        self.stopped = stopped
        self.exportedNoticeIds = exportedNoticeIds
    }
}
