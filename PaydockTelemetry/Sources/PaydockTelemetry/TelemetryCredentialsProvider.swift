//
//  TelemetryCredentialsProvider.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Endpoint and authorization, or nil when none are configured (D5).
package protocol TelemetryCredentialsProvider: Sendable {
    func credentials() -> TelemetryCredentials?
}
