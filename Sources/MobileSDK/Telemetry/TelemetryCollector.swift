//
//  TelemetryCollector.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

/// R_01: the collector each environment sends to. Exhaustive over `SDKEnvironment`, so a new environment is a compile
/// error until it is given its collector, and production stays explicitly off.
enum TelemetryCollector {
    /// The dev collector, which takes records without an `Authorization` header (D22).
    static let devLogsURL = "https://mobile-telemetry-dev.shared.apac.paydock.com/v1/logs"

    /// sandbox, staging → `devLogsURL`; production → nil (until the platform team delivers the prod route).
    static func logsURL(for environment: SDKEnvironment) -> String? {
        switch environment {
        case .sandbox, .staging:
            return devLogsURL
        case .production:
            return nil
        }
    }
}
