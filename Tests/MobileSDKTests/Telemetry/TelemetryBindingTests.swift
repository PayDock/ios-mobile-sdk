//
//  TelemetryBindingTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

#if DEBUG
import Foundation
import XCTest
@testable import MobileSDK
import PaydockTelemetry

final class TelemetryBindingTests: XCTestCase {

    private static let endpoint = "https://otlp.invalid/v1/logs"
    private static let authorization = "synthetic-not-a-credential"
    private static let paydockHost = "com.paydock.multitenant.sandbox"
    private static let merchantHost = "com.merchant.shop"

    private static let fullEnvironment = [
        EnvironmentCredentialsProvider.endpointKey: endpoint,
        EnvironmentCredentialsProvider.authorizationKey: authorization
    ]

    override func tearDown() {
        TelemetryBinding.bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
        super.tearDown()
    }

    // MARK: - EnvironmentCredentialsProvider

    func testEnvironmentProvider_BothVariablesSet_GivesCredentials() {
        let credentials = EnvironmentCredentialsProvider(environment: Self.fullEnvironment).credentials()

        XCTAssertEqual(credentials, TelemetryCredentials(endpoint: Self.endpoint, authorization: Self.authorization))
    }

    func testEnvironmentProvider_EitherVariableMissing_GivesNil() {
        for key in [EnvironmentCredentialsProvider.endpointKey, EnvironmentCredentialsProvider.authorizationKey] {
            var environment = Self.fullEnvironment
            environment[key] = nil

            XCTAssertNil(EnvironmentCredentialsProvider(environment: environment).credentials(), "\(key) missing")
        }
    }

    func testEnvironmentProvider_EitherVariableBlank_GivesNil() {
        for key in [EnvironmentCredentialsProvider.endpointKey, EnvironmentCredentialsProvider.authorizationKey] {
            for blank in ["", "   "] {
                var environment = Self.fullEnvironment
                environment[key] = blank

                XCTAssertNil(EnvironmentCredentialsProvider(environment: environment).credentials(), "\(key) blank")
            }
        }
    }

    // MARK: - selectTelemetry

    func testSelect_WithoutCredentials_GivesNoOp() {
        assertNoOp(select(provider: StubCredentialsProvider(value: nil)))
    }

    func testSelect_ProductionOrStaging_GivesNoOp() {
        assertNoOp(select(environment: .production))
        assertNoOp(select(environment: .staging))
    }

    func testSelect_LevelOff_GivesNoOp() {
        assertNoOp(select(level: .off))
    }

    func testSelect_NilOrMerchantHost_GivesNoOp() {
        assertNoOp(select(host: nil))
        assertNoOp(select(host: Self.merchantHost))
    }

    func testSelect_EveryConditionHolds_GivesOneActiveTelemetryAsBothHandles() throws {
        let selection = select()

        let telemetry = try XCTUnwrap(selection.telemetry as? ActiveTelemetry)
        let runtime = try XCTUnwrap(selection.runtime as? ActiveTelemetry)
        XCTAssertTrue(telemetry === runtime)
        XCTAssertTrue(telemetry.isActive)
        XCTAssertEqual(telemetry.credentials, TelemetryCredentials(endpoint: Self.endpoint, authorization: Self.authorization))
        XCTAssertEqual(telemetry.level, .all)
    }

    // MARK: - bind

    func testBind_Active_MakesTheFacadeCurrent_AndStartsOnce() {
        let facade = FakeTelemetry(isActive: true)
        let runtime = CountingRuntime()

        let bound = TelemetryBinding.bind(TelemetrySelection(telemetry: facade, runtime: runtime))

        XCTAssertTrue((bound as? FakeTelemetry) === facade)
        XCTAssertTrue((TelemetryBinding.current as? FakeTelemetry) === facade)
        XCTAssertEqual(runtime.startCount, 1)
    }

    func testBind_Inactive_MakesTheFacadeCurrent_AndNeverStarts() {
        let facade = FakeTelemetry(isActive: false)
        let runtime = CountingRuntime()

        TelemetryBinding.bind(TelemetrySelection(telemetry: facade, runtime: runtime))

        XCTAssertTrue((TelemetryBinding.current as? FakeTelemetry) === facade)
        XCTAssertEqual(runtime.startCount, 0)
    }

    func testBind_Rebinding_ReplacesTheFacade() {
        let first = FakeTelemetry(isActive: false)
        let second = FakeTelemetry(isActive: false)

        TelemetryBinding.bind(TelemetrySelection(telemetry: first, runtime: CountingRuntime()))
        TelemetryBinding.bind(TelemetrySelection(telemetry: second, runtime: CountingRuntime()))

        XCTAssertTrue((TelemetryBinding.current as? FakeTelemetry) === second)
        XCTAssertTrue((MobileSDK.shared.telemetry as? FakeTelemetry) === second)
    }

    // MARK: - Helpers

    private func select(
        provider: any TelemetryCredentialsProvider = StubCredentialsProvider(
            value: TelemetryCredentials(endpoint: TelemetryBindingTests.endpoint, authorization: TelemetryBindingTests.authorization)
        ),
        environment: SDKEnvironment = .sandbox,
        level: TelemetryLevel = .all,
        host: String? = TelemetryBindingTests.paydockHost
    ) -> TelemetrySelection {
        selectTelemetry(
            credentialsProvider: provider,
            sdkEnvironment: environment,
            level: level,
            hostBundleIdentifier: host
        )
    }

    private func assertNoOp(_ selection: TelemetrySelection, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(selection.telemetry is NoOpTelemetry, file: file, line: line)
        XCTAssertTrue(selection.runtime is NoOpTelemetry, file: file, line: line)
        XCTAssertFalse(selection.telemetry.isActive, file: file, line: line)
    }
}

private struct StubCredentialsProvider: TelemetryCredentialsProvider {
    let value: TelemetryCredentials?

    func credentials() -> TelemetryCredentials? { value }
}

private final class FakeTelemetry: Telemetry {
    let isActive: Bool

    init(isActive: Bool) {
        self.isActive = isActive
    }

    func report(_ event: TelemetryEvent) {}
}

private final class CountingRuntime: TelemetryRuntime, @unchecked Sendable {
    private let lock = NSLock()
    private var starts = 0

    var startCount: Int { lock.withLock { starts } }

    func start() {
        lock.withLock { starts += 1 }
    }
}
#endif
