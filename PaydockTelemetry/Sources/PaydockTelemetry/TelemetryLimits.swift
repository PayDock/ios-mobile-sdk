//
//  TelemetryLimits.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The spec § 6 parameters, in one place; every other type reads them from here.
package enum TelemetryLimits {
    package static let flushIntervalMilliseconds: Int64 = 10_000
    /// Pending records that trigger an export at once.
    package static let flushThreshold = 20
    package static let batchMaxRecords = 50
    /// JSON before gzip.
    package static let batchMaxBytes = 262_144
    package static let storeMaxRecords = 100
    package static let storeMaxBytes = 1_048_576
    /// 156 h.
    package static let recordMaxAgeMilliseconds: Int64 = 561_600_000
    package static let requestTimeoutSeconds: TimeInterval = 15
    package static let retryMaxAttempts = 5
    package static let retryBaseDelayMilliseconds: Int64 = 5_000
    package static let retryMaxDelayMilliseconds: Int64 = 60_000
    /// The longest `Retry-After` honoured: a larger one from a misbehaving gateway would stop sending for the process.
    package static let retryAfterMaxMilliseconds: Int64 = 3_600_000
    /// Records created per hour, notices excluded.
    package static let hourlyCap = 400
    package static let hourMilliseconds: Int64 = 3_600_000
    /// The longest the crashing thread waits for a store's lock before it gives up the record.
    package static let crashLockTimeoutSeconds: TimeInterval = 0.5
    /// Builds whose SDK ranges are kept for the frame classifier, the current one included.
    package static let frameBuildsKept = 3
    /// Payment attempts open at once (started, not finished); the oldest is forgotten past it.
    package static let maxOpenPayments = 20
}
