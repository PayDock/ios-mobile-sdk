//
//  TelemetryActivation.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// The one activation decision. Pure: the SDK passes in what the target cannot see.
package enum TelemetryActivation {
    /// R_02: a non-blank endpoint and a level other than off.
    package static func isActive(credentials: TelemetryCredentials?, level: TelemetryLevel) -> Bool {
        guard let credentials else {
            return false
        }
        return !credentials.endpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && level != .off
    }
}
