//
//  SdkTelemetryCredentialsProvider.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import PaydockTelemetry

/// R_01, R_03: the override's credentials when `override` is non-nil and its endpoint is non-blank; else the
/// environment's collector URL with authorization ""; nil when the environment has none. The override exists only in
/// debug builds, so a release build always takes the collector.
struct SdkTelemetryCredentialsProvider: TelemetryCredentialsProvider {
    let environment: SDKEnvironment
    #if DEBUG
    let override: LocalTelemetryOverride?

    init(environment: SDKEnvironment, override: LocalTelemetryOverride? = nil) {
        self.environment = environment
        self.override = override
    }
    #else
    init(environment: SDKEnvironment) {
        self.environment = environment
    }
    #endif

    func credentials() -> TelemetryCredentials? {
        #if DEBUG
        if let override, !override.endpoint.isEmpty {
            return TelemetryCredentials(endpoint: override.endpoint, authorization: override.authorization)
        }
        #endif
        guard let url = TelemetryCollector.logsURL(for: environment) else {
            return nil
        }
        return TelemetryCredentials(endpoint: url, authorization: "")
    }
}
