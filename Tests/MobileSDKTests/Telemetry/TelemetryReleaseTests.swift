//
//  TelemetryReleaseTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest
@testable import MobileSDK
import PaydockTelemetry

/// R_01–R_04, R_11, R_14: what a release build binds, checked in the Release configuration (`ENABLE_TESTABILITY=YES`):
/// sandbox and staging send to the dev collector with no credential at level `all`, production binds the no-op, the
/// override variables are never read, a test process binds the no-op, and the exporter sends exactly the two content
/// headers. Compiled in every configuration; in a debug build it only reports that it must run in Release.
final class TelemetryReleaseTests: XCTestCase {

    #if DEBUG
    /// Skipped, not failed, so the debug `MobileSDKTests` run stays green; the result names the configuration to use.
    func testRunsInTheReleaseConfiguration() throws {
        throw XCTSkip("run in the Release configuration")
    }
    #else
    private static let overrideVariables = [
        "PAYDOCK_TELEMETRY_OTLP_ENDPOINT": "https://otlp.invalid/v1/logs",
        "PAYDOCK_TELEMETRY_OTLP_AUTH": "synthetic-not-a-credential",
        "PAYDOCK_TELEMETRY_LEVEL": "errors"
    ]
    private static let paydockHost = "com.paydock.multitenant.sandbox"

    override func tearDown() {
        TelemetryBinding.bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
        super.tearDown()
    }

    func testSandboxAndStaging_SelectTheCollector_WithoutACredential_AtAll() throws {
        for environment in [SDKEnvironment.sandbox, .staging] {
            let selection = Self.select(environment)

            let telemetry = try XCTUnwrap(selection.telemetry as? ActiveTelemetry, environment.rawValue)
            XCTAssertTrue(selection.runtime as? ActiveTelemetry === telemetry, environment.rawValue)
            XCTAssertEqual(telemetry.credentials,
                           TelemetryCredentials(endpoint: TelemetryCollector.devLogsURL, authorization: ""),
                           environment.rawValue)
            XCTAssertEqual(telemetry.level, .all, environment.rawValue)
        }
    }

    func testProduction_SelectsTheNoOp() {
        let selection = Self.select(.production)

        XCTAssertTrue(selection.telemetry is NoOpTelemetry)
        XCTAssertTrue(selection.runtime is NoOpTelemetry)
    }

    /// R_03: a Paydock app's override variables are not read by a release build: outside a test process it binds the
    /// collector at `all`.
    func testBindTelemetry_WithTheOverrideVariables_BindsTheCollector() throws {
        let bound = TelemetryBinding.bindTelemetry(environment: .sandbox, processEnvironment: Self.overrideVariables,
                                                   hostBundleIdentifier: Self.paydockHost)

        let telemetry = try XCTUnwrap(bound as? ActiveTelemetry)
        XCTAssertEqual(telemetry.credentials,
                       TelemetryCredentials(endpoint: TelemetryCollector.devLogsURL, authorization: ""))
        XCTAssertEqual(telemetry.level, .all)
    }

    /// R_14: the test runner's bundle ID, or `XCTestConfigurationFilePath`, binds the no-op.
    func testBindTelemetry_InATestProcess_BindsTheNoOp() {
        let withTheKey = Self.overrideVariables.merging([TelemetryTestHost.configurationKey: "/tmp/run.xctestconfiguration"]) { $1 }

        let byBundle = TelemetryBinding.bindTelemetry(environment: .sandbox, processEnvironment: Self.overrideVariables,
                                                      hostBundleIdentifier: TelemetryTestHost.testRunnerBundleIdentifier)
        XCTAssertTrue(byBundle is NoOpTelemetry)
        XCTAssertTrue(TelemetryBinding.current is NoOpTelemetry)

        let byKey = TelemetryBinding.bindTelemetry(environment: .sandbox, processEnvironment: withTheKey,
                                                   hostBundleIdentifier: Self.paydockHost)
        XCTAssertTrue(byKey is NoOpTelemetry)
        XCTAssertTrue(TelemetryBinding.current is NoOpTelemetry)
    }

    /// R_04, R_05: the collector's request goes to the dev URL with exactly the two content headers.
    func testExporter_OnTheCollector_SendsToTheDevURL_WithTheTwoContentHeaders() throws {
        let credentials = try XCTUnwrap(SdkTelemetryCredentialsProvider(environment: .sandbox).credentials())
        let transport = RecordingEndpointTransport(endpoint: credentials.endpoint)
        let exporter = OtlpExporter(transport: transport, credentials: credentials)

        XCTAssertEqual(exporter.export(ExportBatch(resource: Self.resource, records: [])), .success(rejectedRecords: 0))

        let request = try XCTUnwrap(transport.requests.first)
        XCTAssertEqual(transport.requests.count, 1)
        XCTAssertEqual("\(request.scheme)://\(request.host)\(request.path)", TelemetryCollector.devLogsURL)
        XCTAssertEqual(request.header, ["Content-Encoding": "gzip", "Content-Type": "application/json"])
    }

    // MARK: - Helpers

    /// A synthetic device context.
    private static let resource = ResourceAttributes(
        serviceVersion: "0.0.0-test", deploymentEnvironmentName: "sandbox", osVersion: "17.0",
        deviceModelIdentifier: "iPhone15,2", appInstallationId: "00000000-0000-4000-8000-000000000001",
        appId: "com.example.release", appVersion: "1.0.0", appDebuggable: false
    )

    /// `selectTelemetry` with the real provider, as a release build reads it (no override), the release level and
    /// the production factory; nothing is started.
    private static func select(_ environment: SDKEnvironment) -> TelemetrySelection {
        selectTelemetry(
            credentialsProvider: SdkTelemetryCredentialsProvider(environment: environment),
            level: .all,
            createActive: {
                ActiveTelemetry.create(credentials: $0, level: $1, sdkVersion: SDKVersion.current,
                                       environmentName: environment.rawValue)
            }
        )
    }
    #endif
}

#if !DEBUG
/// Records each request as the real transport would build it (`TelemetryEndpoint` from the credential's endpoint), and
/// answers 204. No network.
private final class RecordingEndpointTransport: TelemetryTransport, @unchecked Sendable {
    private let endpoint: String
    private let lock = NSLock()
    private var recorded: [TelemetryEndpoint] = []

    init(endpoint: String) {
        self.endpoint = endpoint
    }

    var requests: [TelemetryEndpoint] { lock.withLock { recorded } }

    func send(_ payload: Data, headers: [String: String]) -> TransportResult {
        guard let request = TelemetryEndpoint(url: endpoint, header: headers, body: payload) else {
            return .failure
        }
        lock.withLock { recorded.append(request) }
        return .success(status: 204, rejectedRecords: 0)
    }
}
#endif
