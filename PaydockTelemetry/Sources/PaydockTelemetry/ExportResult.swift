//
//  ExportResult.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// What an export attempt came to.
package enum ExportResult: Sendable, Equatable {
    case success, retry, drop
}
