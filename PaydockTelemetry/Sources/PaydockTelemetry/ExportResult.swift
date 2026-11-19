//
//  ExportResult.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// What one export attempt came to (R_12).
package enum ExportResult: Sendable, Equatable {
    /// Partial success: the records the gateway refused.
    case success(rejectedRecords: Int64)
    /// No connection, a timeout, a failure, 408, 429 or a 5xx.
    case retry(retryAfterMilliseconds: Int64?)
    /// 401, 403: the collector refuses this app; sending stops for the process.
    case unauthorized
    /// 413.
    case tooLarge
    /// Any other non-2xx.
    case rejected
}
