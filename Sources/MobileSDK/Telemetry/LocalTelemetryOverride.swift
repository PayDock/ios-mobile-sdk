//
//  LocalTelemetryOverride.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

#if DEBUG
import Foundation
import PaydockTelemetry

/// R_03: the scheme variables, read only in a debug build of a Paydock app. Compiled only in debug builds, so a release
/// binary carries neither the keys nor the reading. A merchant's debug build compiles the SDK with DEBUG set too, so the
/// host app's bundle identifier is what keeps a merchant's scheme variables from redirecting records.
struct LocalTelemetryOverride: Equatable {
    static let endpointKey = "PAYDOCK_TELEMETRY_OTLP_ENDPOINT"
    static let authorizationKey = "PAYDOCK_TELEMETRY_OTLP_AUTH"
    static let levelKey = "PAYDOCK_TELEMETRY_LEVEL"
    /// `true` (any case) makes an active runtime store and send one test record right after start (R_16).
    static let sendTestRecordKey = "PAYDOCK_TELEMETRY_SEND_TEST_RECORD"
    /// `true` (any case) makes an active runtime raise a test Objective-C exception from SDK code on the main thread
    /// 3 s after start (R_13).
    static let testCrashKey = "PAYDOCK_TELEMETRY_TEST_CRASH"
    /// Bundle-identifier prefix of Paydock's own host apps.
    static let paydockBundlePrefix = "com.paydock."

    /// Trimmed; empty when the variable is absent or blank.
    let endpoint: String
    /// Trimmed, may be empty: no Authorization header is then sent.
    let authorization: String
    /// `TelemetryLevel.parse` of the level variable.
    let level: TelemetryLevel
    let sendTestRecord: Bool
    let raiseTestCrash: Bool

    /// Nil unless `hostBundleIdentifier` starts with `paydockBundlePrefix`; the values from `environment`.
    static func read(environment: [String: String], hostBundleIdentifier: String?) -> LocalTelemetryOverride? {
        guard hostBundleIdentifier?.hasPrefix(paydockBundlePrefix) ?? false else {
            return nil
        }
        return LocalTelemetryOverride(
            endpoint: trimmed(environment[endpointKey]),
            authorization: trimmed(environment[authorizationKey]),
            level: TelemetryLevel.parse(environment[levelKey]),
            sendTestRecord: environment[sendTestRecordKey]?.lowercased() == "true",
            raiseTestCrash: environment[testCrashKey]?.lowercased() == "true"
        )
    }

    private static func trimmed(_ value: String?) -> String {
        (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
#endif
