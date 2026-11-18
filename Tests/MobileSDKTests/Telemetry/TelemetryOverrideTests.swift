//
//  TelemetryOverrideTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

#if DEBUG
import Foundation
import XCTest
@testable import MobileSDK
import PaydockTelemetry

/// R_01, R_03: the collector table, the credentials provider and the local override limited to Paydock debug apps,
/// through `selectTelemetry` with the production factory. Nothing is bound or started, so nothing is written or sent.
final class TelemetryOverrideTests: XCTestCase {

    private static let endpoint = "https://otlp.invalid/v1/logs"
    private static let authorization = "synthetic-not-a-credential"
    private static let paydockHost = "com.paydock.multitenant.sandbox"
    private static let merchantHost = "com.merchant.shop"

    private static let fullEnvironment = [
        LocalTelemetryOverride.endpointKey: endpoint,
        LocalTelemetryOverride.authorizationKey: authorization
    ]

    private var factory = CreateCounter()

    // MARK: - TelemetryCollector

    /// R_01: the collector table pins the literal URL, and production has none.
    func testCollector_SandboxAndStaging_GiveTheDevURL_ProductionNone() {
        XCTAssertEqual(TelemetryCollector.devLogsURL, "https://mobile-telemetry-dev.shared.apac.paydock.com/v1/logs")
        XCTAssertEqual(TelemetryCollector.logsURL(for: .sandbox), TelemetryCollector.devLogsURL)
        XCTAssertEqual(TelemetryCollector.logsURL(for: .staging), TelemetryCollector.devLogsURL)
        XCTAssertNil(TelemetryCollector.logsURL(for: .production))
    }

    // MARK: - LocalTelemetryOverride

    func testOverride_TheFiveVariablesAndThePrefix() {
        XCTAssertEqual(LocalTelemetryOverride.endpointKey, "PAYDOCK_TELEMETRY_OTLP_ENDPOINT")
        XCTAssertEqual(LocalTelemetryOverride.authorizationKey, "PAYDOCK_TELEMETRY_OTLP_AUTH")
        XCTAssertEqual(LocalTelemetryOverride.levelKey, "PAYDOCK_TELEMETRY_LEVEL")
        XCTAssertEqual(LocalTelemetryOverride.sendTestRecordKey, "PAYDOCK_TELEMETRY_SEND_TEST_RECORD")
        XCTAssertEqual(LocalTelemetryOverride.testCrashKey, "PAYDOCK_TELEMETRY_TEST_CRASH")
        XCTAssertEqual(LocalTelemetryOverride.paydockBundlePrefix, "com.paydock.")
    }

    func testOverride_PaydockHost_ReadsTheTrimmedValues() {
        let environment = [
            LocalTelemetryOverride.endpointKey: "  \(Self.endpoint) ",
            LocalTelemetryOverride.authorizationKey: " \(Self.authorization)\n",
            LocalTelemetryOverride.levelKey: "Errors",
            LocalTelemetryOverride.sendTestRecordKey: "TRUE",
            LocalTelemetryOverride.testCrashKey: "true"
        ]

        let override = LocalTelemetryOverride.read(environment: environment, hostBundleIdentifier: Self.paydockHost)

        XCTAssertEqual(override, LocalTelemetryOverride(endpoint: Self.endpoint, authorization: Self.authorization,
                                                        level: .errors, sendTestRecord: true, raiseTestCrash: true))
    }

    func testOverride_PaydockHost_NoVariables_IsEmptyAtLevelAll() {
        let override = LocalTelemetryOverride.read(environment: [:], hostBundleIdentifier: Self.paydockHost)

        XCTAssertEqual(override, LocalTelemetryOverride(endpoint: "", authorization: "", level: .all,
                                                        sendTestRecord: false, raiseTestCrash: false))
    }

    /// R_03: a merchant's scheme variables are never read.
    func testOverride_MerchantOrNilHost_IsNil() {
        var environment = Self.fullEnvironment
        environment[LocalTelemetryOverride.levelKey] = "errors"
        environment[LocalTelemetryOverride.sendTestRecordKey] = "true"
        environment[LocalTelemetryOverride.testCrashKey] = "true"

        XCTAssertNil(LocalTelemetryOverride.read(environment: environment, hostBundleIdentifier: Self.merchantHost))
        XCTAssertNil(LocalTelemetryOverride.read(environment: environment, hostBundleIdentifier: nil))
        XCTAssertNil(LocalTelemetryOverride.read(environment: environment, hostBundleIdentifier: "com.paydockx.app"))
    }

    // MARK: - SdkTelemetryCredentialsProvider and the collector path

    /// R_01: sandbox and staging with no override → active, the dev URL, authorization empty, level `all`.
    func testCollectorPath_SandboxAndStaging_GiveActiveTelemetryOnTheCollector() throws {
        for environment in [SDKEnvironment.sandbox, .staging] {
            factory = CreateCounter()
            let provider = SdkTelemetryCredentialsProvider(environment: environment, override: nil)

            let selection = select(provider: provider, level: TelemetryBinding.level(for: nil))

            let telemetry = try XCTUnwrap(selection.telemetry as? ActiveTelemetry, "\(environment)")
            XCTAssertEqual(telemetry.credentials,
                           TelemetryCredentials(endpoint: TelemetryCollector.devLogsURL, authorization: ""))
            XCTAssertEqual(telemetry.level, .all)
            XCTAssertEqual(factory.callCount, 1)
        }
    }

    /// R_01: production → no-op, and the factory is never called.
    func testCollectorPath_Production_GivesNoOp_AndCreatesNothing() {
        let provider = SdkTelemetryCredentialsProvider(environment: .production, override: nil)

        XCTAssertNil(provider.credentials())
        let selection = select(provider: provider, level: TelemetryBinding.level(for: nil))
        XCTAssertTrue(selection.telemetry is NoOpTelemetry)
        XCTAssertTrue(selection.runtime is NoOpTelemetry)
        XCTAssertEqual(factory.callCount, 0)
    }

    /// R_03: a debug Paydock app's endpoint wins in every environment, production included, with its auth.
    func testOverride_WithAnEndpoint_WinsInEveryEnvironment() throws {
        let override = try XCTUnwrap(LocalTelemetryOverride.read(environment: Self.fullEnvironment,
                                                                 hostBundleIdentifier: Self.paydockHost))
        for environment in [SDKEnvironment.production, .sandbox, .staging] {
            factory = CreateCounter()
            let provider = SdkTelemetryCredentialsProvider(environment: environment, override: override)

            let selection = select(provider: provider, level: TelemetryBinding.level(for: override))

            let telemetry = try XCTUnwrap(selection.telemetry as? ActiveTelemetry, "\(environment)")
            XCTAssertEqual(telemetry.credentials,
                           TelemetryCredentials(endpoint: Self.endpoint, authorization: Self.authorization))
        }
    }

    func testOverride_WithAnEndpoint_TakesItsLevel() throws {
        var environment = Self.fullEnvironment
        environment[LocalTelemetryOverride.levelKey] = "errors"
        let override = LocalTelemetryOverride.read(environment: environment, hostBundleIdentifier: Self.paydockHost)

        XCTAssertEqual(TelemetryBinding.level(for: override), .errors)
    }

    /// R_03: an empty auth sends no credential.
    func testOverride_WithAnEmptyAuth_SendsNoCredential() throws {
        var environment = Self.fullEnvironment
        environment[LocalTelemetryOverride.authorizationKey] = "  "
        let override = LocalTelemetryOverride.read(environment: environment, hostBundleIdentifier: Self.paydockHost)

        let credentials = SdkTelemetryCredentialsProvider(environment: .sandbox, override: override).credentials()

        XCTAssertEqual(credentials, TelemetryCredentials(endpoint: Self.endpoint, authorization: ""))
    }

    /// R_03, R_04: with no endpoint the provider falls back to the environment's collector, at the override's level:
    /// a Paydock debug app takes the local level with or without an endpoint.
    func testOverride_WithoutAnEndpoint_FallsBackToTheCollector_AtTheLocalLevel() throws {
        var environment = Self.fullEnvironment
        environment[LocalTelemetryOverride.endpointKey] = " "
        environment[LocalTelemetryOverride.levelKey] = "errors"
        let override = try XCTUnwrap(LocalTelemetryOverride.read(environment: environment,
                                                                 hostBundleIdentifier: Self.paydockHost))

        let selection = select(provider: SdkTelemetryCredentialsProvider(environment: .staging, override: override),
                               level: TelemetryBinding.level(for: override))

        let telemetry = try XCTUnwrap(selection.telemetry as? ActiveTelemetry)
        XCTAssertEqual(telemetry.credentials, TelemetryCredentials(endpoint: TelemetryCollector.devLogsURL, authorization: ""))
        XCTAssertEqual(telemetry.level, .errors)
        XCTAssertNil(SdkTelemetryCredentialsProvider(environment: .production, override: override).credentials())
    }

    /// R_04: a Paydock debug app's level `off` turns the collector path off, with no endpoint set.
    func testOverride_WithoutAnEndpoint_AtLevelOff_GivesNoOp_AndCreatesNothing() throws {
        let override = try XCTUnwrap(LocalTelemetryOverride.read(environment: [LocalTelemetryOverride.levelKey: "off"],
                                                                 hostBundleIdentifier: Self.paydockHost))

        let selection = select(provider: SdkTelemetryCredentialsProvider(environment: .sandbox, override: override),
                               level: TelemetryBinding.level(for: override))

        XCTAssertTrue(selection.telemetry is NoOpTelemetry)
        XCTAssertEqual(factory.callCount, 0)
    }

    func testLevel_WithoutAnOverride_IsAll() {
        XCTAssertEqual(TelemetryBinding.level(for: nil), .all)
    }

    /// R_03: a merchant bundle ID or a nil bundle ID ignores every override variable: the collector at `all`.
    func testOverride_MerchantOrNilHost_GivesTheCollectorAtAll() throws {
        var environment = Self.fullEnvironment
        environment[LocalTelemetryOverride.levelKey] = "off"
        for host in [Self.merchantHost, nil] {
            factory = CreateCounter()
            let override = LocalTelemetryOverride.read(environment: environment, hostBundleIdentifier: host)

            let selection = select(provider: SdkTelemetryCredentialsProvider(environment: .sandbox, override: override),
                                   level: TelemetryBinding.level(for: override))

            let telemetry = try XCTUnwrap(selection.telemetry as? ActiveTelemetry, "\(host ?? "nil")")
            XCTAssertEqual(telemetry.credentials,
                           TelemetryCredentials(endpoint: TelemetryCollector.devLogsURL, authorization: ""))
            XCTAssertEqual(telemetry.level, .all)
        }
    }

    // MARK: - Helpers

    private func select(provider: any TelemetryCredentialsProvider, level: TelemetryLevel) -> TelemetrySelection {
        selectTelemetry(credentialsProvider: provider, level: level, createActive: factory.make)
    }
}

/// `ActiveTelemetry.create`, counted. Creating does no I/O; only `start()` would.
private final class CreateCounter {
    private(set) var callCount = 0

    func make(credentials: TelemetryCredentials, level: TelemetryLevel) -> ActiveTelemetry {
        callCount += 1
        return ActiveTelemetry.create(credentials: credentials, level: level, sdkVersion: SDKVersion.current,
                                      environmentName: SDKEnvironment.sandbox.rawValue)
    }
}
#endif
