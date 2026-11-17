//
//  PruneResult.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// What a prune removed and counts as dropped: notices are never counted.
package struct PruneResult: Sendable, Equatable {
    package var tooOld = 0
    package var storeFull = 0

    package init(tooOld: Int = 0, storeFull: Int = 0) {
        self.tooOld = tooOld
        self.storeFull = storeFull
    }
}
