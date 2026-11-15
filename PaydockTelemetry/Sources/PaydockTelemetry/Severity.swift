//
//  Severity.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// A record's OTLP severity (spec § 5.2).
package enum Severity: Int, Sendable, Equatable {
    case info = 9, warn = 13, error = 17, fatal = 21

    /// The OTLP `severityText`.
    package var text: String {
        switch self {
        case .info: return "INFO"
        case .warn: return "WARN"
        case .error: return "ERROR"
        case .fatal: return "FATAL"
        }
    }
}
