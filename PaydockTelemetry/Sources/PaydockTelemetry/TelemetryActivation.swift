//
//  TelemetryActivation.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// The one activation decision (RS-1). Pure: the SDK passes in what the target cannot see.
package enum TelemetryActivation {
    /// Bundle-identifier prefix of Paydock's own host apps. A merchant's debug build compiles the SDK with DEBUG
    /// set, so the host app is what keeps a merchant build out.
    package static let paydockHostPrefix = "com.paydock."

    /// True only when every condition holds: credentials, sandbox, a level other than off, a Paydock host app.
    package static func isActive(
        credentials: TelemetryCredentials?,
        isSandbox: Bool,
        level: TelemetryLevel,
        hostBundleIdentifier: String?
    ) -> Bool {
        credentials != nil && isSandbox && level != .off && (hostBundleIdentifier?.hasPrefix(paydockHostPrefix) ?? false)
    }
}
