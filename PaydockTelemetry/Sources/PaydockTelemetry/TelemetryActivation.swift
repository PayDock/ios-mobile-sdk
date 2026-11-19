//
//  TelemetryActivation.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The one activation decision. Pure: the SDK passes in what the target cannot see.
package enum TelemetryActivation {
    /// R_02: a non-blank (trimmed) endpoint.
    package static func isActive(endpoint: String?) -> Bool {
        guard let endpoint else {
            return false
        }
        return !endpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
