//
//  TelemetryLevel.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// How much telemetry records: nothing, errors only, or everything. Applied by the activation slice (MD-33).
package enum TelemetryLevel: Sendable, Equatable {
    case off, errors, all

    /// Absent or blank → `.all` (D3); a level name, case-insensitive and trimmed → that level; anything else → `.off`.
    package static func parse(_ raw: String?) -> TelemetryLevel {
        let name = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch name {
        case "":
            return .all
        case "off":
            return .off
        case "errors":
            return .errors
        case "all":
            return .all
        default:
            return .off
        }
    }
}
