//
//  TelemetryReleaseTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest
@testable import MobileSDK
import NetworkingLib
import PaydockTelemetry

/// R_01, R_02, R_05, R_14: what a release build binds, checked in the Release configuration (`ENABLE_TESTABILITY=YES`):
/// sandbox and staging select the dev collector, production the prod collector, a Paydock app with every former
/// `PAYDOCK_TELEMETRY_*` variable set still binds its environment's collector, a test process binds the no-op, and the
/// exporter sends exactly the two content headers. Compiled in every configuration; in a debug build it only
/// reports that it must run in Release.
final class TelemetryReleaseTests: XCTestCase {

    #if DEBUG
    /// Skipped, not failed, so the debug `MobileSDKTests` run stays green; the result names the configuration to use.
    func testRunsInTheReleaseConfiguration() throws {
        throw XCTSkip("run in the Release configuration")
    }
    #else
    private static let appBundleIdentifier = "com.paydock.multitenant.sandbox"
    /// Every variable the removed debug override read, with synthetic values that would each have changed the binding.
    private static let formerVariables = [
        "PAYDOCK_TELEMETRY_OTLP_ENDPOINT": "https://otlp.invalid/v1/logs",
        "PAYDOCK_TELEMETRY_OTLP_AUTH": "synthetic-not-a-credential",
        "PAYDOCK_TELEMETRY_LEVEL": "off",
        "PAYDOCK_TELEMETRY_SEND_TEST_RECORD": "true",
        "PAYDOCK_TELEMETRY_TEST_CRASH": "true"
    ]

    override func tearDown() {
        TelemetryBinding.bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
        super.tearDown()
    }

    func testSandboxAndStaging_SelectTheDevCollector() throws {
        for environment in [SDKEnvironment.sandbox, .staging] {
            let selection = Self.select(environment)

            let telemetry = try XCTUnwrap(selection.telemetry as? ActiveTelemetry, environment.rawValue)
            XCTAssertTrue(selection.runtime as? ActiveTelemetry === telemetry, environment.rawValue)
            XCTAssertEqual(telemetry.endpoint, TelemetryCollector.devLogsURL, environment.rawValue)
        }
    }

    func testProduction_SelectsTheProdCollector() throws {
        let selection = Self.select(.production)

        let telemetry = try XCTUnwrap(selection.telemetry as? ActiveTelemetry)
        XCTAssertTrue(selection.runtime as? ActiveTelemetry === telemetry)
        XCTAssertEqual(telemetry.endpoint, TelemetryCollector.prodLogsURL)
        XCTAssertEqual(TelemetryCollector.prodLogsURL, "https://mobile-telemetry.shared.apac.paydock.com/v1/logs")
    }

    /// R_02 (`TelemetryNoLocalValues`): binds as a Paydock app (`com.paydock.` host) outside a test process would, with
    /// every former variable set: the bound runtime sends to sandbox's collector, not the former endpoint, and is active
    /// although the former level was `off`. This starts a real runtime on the dev collector in the Release test process,
    /// never in the debug suite; the request observer and the uncaught-exception handler it registers are put back
    /// afterwards.
    func testBindTelemetry_WithEveryFormerVariable_InAPaydockApp_BindsTheEnvironmentsCollector() throws {
        let observerBefore = NetworkingLib.shared.requestObserver
        let handlerBefore = NSGetUncaughtExceptionHandler()
        defer {
            NetworkingLib.shared.requestObserver = observerBefore
            NSSetUncaughtExceptionHandler(handlerBefore)
        }
        XCTAssertFalse(TelemetryTestHost.isTestProcess(environment: Self.formerVariables,
                                                       bundleIdentifier: Self.appBundleIdentifier))

        let bound = TelemetryBinding.bindTelemetry(environment: .sandbox, processEnvironment: Self.formerVariables,
                                                   hostBundleIdentifier: Self.appBundleIdentifier)

        let telemetry = try XCTUnwrap(bound as? ActiveTelemetry)
        XCTAssertTrue(telemetry.isActive)
        XCTAssertEqual(telemetry.endpoint, TelemetryCollector.devLogsURL)
        XCTAssertTrue((TelemetryBinding.current as? ActiveTelemetry) === telemetry)
    }

    /// R_14: the test runner's bundle ID, or `XCTestConfigurationFilePath`, binds the no-op.
    func testBindTelemetry_InATestProcess_BindsTheNoOp() {
        let byBundle = TelemetryBinding.bindTelemetry(environment: .sandbox, processEnvironment: [:],
                                                      hostBundleIdentifier: TelemetryTestHost.testRunnerBundleIdentifier)
        XCTAssertTrue(byBundle is NoOpTelemetry)
        XCTAssertTrue(TelemetryBinding.current is NoOpTelemetry)

        let byKey = TelemetryBinding.bindTelemetry(
            environment: .production,
            processEnvironment: [TelemetryTestHost.configurationKey: "/tmp/run.xctestconfiguration"],
            hostBundleIdentifier: Self.appBundleIdentifier
        )
        XCTAssertTrue(byKey is NoOpTelemetry)
        XCTAssertTrue(TelemetryBinding.current is NoOpTelemetry)
    }

    /// R_05: each collector's request goes to its URL with exactly the two content headers.
    func testExporter_OnEachCollector_SendsToItsURL_WithTheTwoContentHeaders() throws {
        for environment in [SDKEnvironment.sandbox, .staging, .production] {
            let url = try XCTUnwrap(TelemetryCollector.logsURL(for: environment), environment.rawValue)
            let transport = RecordingEndpointTransport(endpoint: url)
            let exporter = OtlpExporter(transport: transport)

            XCTAssertEqual(exporter.export(ExportBatch(resource: Self.resource, records: [])), .success(rejectedRecords: 0),
                           environment.rawValue)

            let request = try XCTUnwrap(transport.requests.first, environment.rawValue)
            XCTAssertEqual(transport.requests.count, 1, environment.rawValue)
            XCTAssertEqual("\(request.scheme)://\(request.host)\(request.path)", url, environment.rawValue)
            XCTAssertEqual(request.header, ["Content-Encoding": "gzip", "Content-Type": "application/json"],
                           environment.rawValue)
        }
    }

    // MARK: - Helpers

    /// A synthetic device context.
    private static let resource = ResourceAttributes(
        serviceVersion: "0.0.0-test", deploymentEnvironmentName: "sandbox", osVersion: "17.0",
        deviceModelIdentifier: "iPhone15,2", appInstallationId: "00000000-0000-4000-8000-000000000001",
        appId: "com.example.release", appVersion: "1.0.0", appDebuggable: false
    )

    /// `selectTelemetry` with the environment's collector and the production factory, as `bindTelemetry` calls it;
    /// nothing is started.
    private static func select(_ environment: SDKEnvironment) -> TelemetrySelection {
        selectTelemetry(
            endpoint: TelemetryCollector.logsURL(for: environment),
            createActive: {
                ActiveTelemetry.create(endpoint: $0, sdkVersion: SDKVersion.current, environmentName: environment.rawValue)
            }
        )
    }
    #endif
}

#if !DEBUG
/// Records each request as the real transport would build it (`TelemetryEndpoint` from the collector's URL), and
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
