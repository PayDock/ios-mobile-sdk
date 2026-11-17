//
//  TransportResult.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// What one send came to. Typed, never thrown (R_03).
package enum TransportResult: Sendable, Equatable {
    /// Any 2xx; `rejectedRecords` from a partial success, 0 when absent.
    case success(status: Int, rejectedRecords: Int64)
    case httpError(status: Int, retryAfterMilliseconds: Int64?)
    case timeout
    /// DNS, refused, reset, TLS, offline.
    case connectionFailure
    /// Anything else.
    case failure
}
