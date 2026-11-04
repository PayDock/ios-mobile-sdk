//
//  TelemetryBinding.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import PaydockTelemetry

/// What the binding chose. SDK code only ever receives `telemetry`; `runtime` stays in this file.
struct TelemetrySelection {
    let telemetry: any Telemetry
    let runtime: any TelemetryRuntime
}

/// The one binding at SDK start (RS-4).
enum TelemetryBinding {
    /// The facade SDK code reads: `NoOpTelemetry` until `bind`.
    static var current: any Telemetry { lock.withLock { bound } }

    /// Selects and binds at `configureMobileSDK`. A release build always binds the no-op (D14).
    @discardableResult
    static func bindTelemetry(environment: SDKEnvironment) -> any Telemetry {
        #if DEBUG
        let env = ProcessInfo.processInfo.environment
        let selection = selectTelemetry(
            credentialsProvider: EnvironmentCredentialsProvider(environment: env),
            sdkEnvironment: environment,
            level: TelemetryLevel.parse(env[EnvironmentCredentialsProvider.levelKey]),
            hostBundleIdentifier: Bundle.main.bundleIdentifier,
            createActive: {
                ActiveTelemetry.create(credentials: $0, level: $1, sdkVersion: SDKVersion.current,
                                       environmentName: environment.rawValue)
            }
        )
        #else
        let selection = TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry())
        #endif
        return bind(selection)
    }

    /// Makes `selection.telemetry` the facade, then calls `selection.runtime.start()` once if it is active.
    @discardableResult
    static func bind(_ selection: TelemetrySelection) -> any Telemetry {
        lock.withLock { bound = selection.telemetry }
        if selection.telemetry.isActive {
            selection.runtime.start()
        }
        return selection.telemetry
    }

    private static let lock = NSLock()
    private static var bound: any Telemetry = NoOpTelemetry()
}

extension MobileSDK {
    /// The telemetry facade for SDK code (RS-4).
    var telemetry: any Telemetry { TelemetryBinding.current }
}

#if DEBUG
/// Reads the local scheme's variables (spec § 8). Compiled only in debug builds (D14).
struct EnvironmentCredentialsProvider: TelemetryCredentialsProvider {
    static let endpointKey = "PAYDOCK_TELEMETRY_OTLP_ENDPOINT"
    static let authorizationKey = "PAYDOCK_TELEMETRY_OTLP_AUTH"
    static let levelKey = "PAYDOCK_TELEMETRY_LEVEL"

    let environment: [String: String]

    /// Nil when the trimmed endpoint or authorization is empty or absent.
    func credentials() -> TelemetryCredentials? {
        guard
            let endpoint = environment[Self.endpointKey]?.trimmingCharacters(in: .whitespacesAndNewlines),
            let authorization = environment[Self.authorizationKey]?.trimmingCharacters(in: .whitespacesAndNewlines),
            !endpoint.isEmpty,
            !authorization.isEmpty
        else {
            return nil
        }
        return TelemetryCredentials(endpoint: endpoint, authorization: authorization)
    }
}

/// The decision with every input injectable: one `ActiveTelemetry` as both handles when active, else `NoOpTelemetry()`.
/// `createActive` is called only when the decision passes, so nothing is created or written while inactive.
func selectTelemetry(
    credentialsProvider: any TelemetryCredentialsProvider,
    sdkEnvironment: SDKEnvironment,
    level: TelemetryLevel,
    hostBundleIdentifier: String?,
    createActive: (TelemetryCredentials, TelemetryLevel) -> ActiveTelemetry
) -> TelemetrySelection {
    let credentials = credentialsProvider.credentials()
    let isActive = TelemetryActivation.isActive(
        credentials: credentials,
        isSandbox: sdkEnvironment == .sandbox,
        level: level,
        hostBundleIdentifier: hostBundleIdentifier
    )
    guard isActive, let credentials else {
        return TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry())
    }
    let active = createActive(credentials, level)
    return TelemetrySelection(telemetry: active, runtime: active)
}
#endif
