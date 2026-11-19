//
//  TelemetryCollector.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

/// R_01: the collector each environment sends to, the binding's only input. Exhaustive over `SDKEnvironment`, so a new
/// environment is a compile error until it is given its collector. No collector takes an `Authorization` header (D22).
enum TelemetryCollector {
    /// The dev collector: sandbox and staging.
    static let devLogsURL = "https://mobile-telemetry-dev.shared.apac.paydock.com/v1/logs"

    /// The prod collector: production.
    static let prodLogsURL = "https://mobile-telemetry.shared.apac.paydock.com/v1/logs"

    /// sandbox, staging → `devLogsURL`; production → `prodLogsURL`. Every environment has a collector; the optional
    /// stays, so an environment can be switched off by returning nil.
    static func logsURL(for environment: SDKEnvironment) -> String? {
        switch environment {
        case .sandbox, .staging:
            return devLogsURL
        case .production:
            return prodLogsURL
        }
    }
}
