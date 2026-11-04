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

    private var factory = CountingActiveFactory()

    override func setUp() {
        super.setUp()
        factory = CountingActiveFactory()
    }

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

    func testSelect_WithoutCredentials_GivesNoOp_AndCreatesNothing() {
        assertNoOp(select(provider: StubCredentialsProvider(value: nil)))
        XCTAssertEqual(factory.callCount, 0)
    }

    func testSelect_ProductionOrStaging_GivesNoOp_AndCreatesNothing() {
        assertNoOp(select(environment: .production))
        assertNoOp(select(environment: .staging))
        XCTAssertEqual(factory.callCount, 0)
    }

    func testSelect_LevelOff_GivesNoOp_AndCreatesNothing() {
        assertNoOp(select(level: .off))
        XCTAssertEqual(factory.callCount, 0)
    }

    func testSelect_NilOrMerchantHost_GivesNoOp_AndCreatesNothing() {
        assertNoOp(select(host: nil))
        assertNoOp(select(host: Self.merchantHost))
        XCTAssertEqual(factory.callCount, 0)
    }

    func testSelect_EveryConditionHolds_CreatesOnce_AndGivesThatActiveTelemetryAsBothHandles() throws {
        let selection = select()

        XCTAssertEqual(factory.callCount, 1)
        let created = try XCTUnwrap(factory.created)
        let telemetry = try XCTUnwrap(selection.telemetry as? ActiveTelemetry)
        let runtime = try XCTUnwrap(selection.runtime as? ActiveTelemetry)
        XCTAssertTrue(telemetry === created)
        XCTAssertTrue(telemetry === runtime)
        XCTAssertTrue(telemetry.isActive)
        XCTAssertEqual(telemetry.credentials, TelemetryCredentials(endpoint: Self.endpoint, authorization: Self.authorization))
        XCTAssertEqual(telemetry.level, .all)
    }

    func testSelect_PassesTheCredentialsAndLevelToTheFactory() {
        select(level: .errors)

        XCTAssertEqual(factory.arguments.map(\.credentials),
                       [TelemetryCredentials(endpoint: Self.endpoint, authorization: Self.authorization)])
        XCTAssertEqual(factory.arguments.map(\.level), [.errors])
    }

    func testSelect_ActiveThenBound_ReadsTheDeviceContextOnStart() throws {
        let selection = select()

        TelemetryBinding.bind(selection)

        let telemetry = try XCTUnwrap(selection.telemetry as? ActiveTelemetry)
        XCTAssertEqual(factory.provider.callCount, 1)
        XCTAssertEqual(telemetry.resourceAttributes, FakeDeviceContextProvider.attributes)
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

    @discardableResult
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
            hostBundleIdentifier: host,
            createActive: factory.make
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

/// Builds `ActiveTelemetry` with an inline dispatcher and a fixed device context, and counts its calls.
private final class CountingActiveFactory {
    let provider = FakeDeviceContextProvider()
    private(set) var arguments: [(credentials: TelemetryCredentials, level: TelemetryLevel)] = []
    private(set) var created: ActiveTelemetry?

    var callCount: Int { arguments.count }

    func make(credentials: TelemetryCredentials, level: TelemetryLevel) -> ActiveTelemetry {
        arguments.append((credentials, level))
        let telemetry = ActiveTelemetry(credentials: credentials, level: level, deviceContextProvider: provider,
                                        dispatcher: ImmediateDispatcher())
        created = telemetry
        return telemetry
    }
}

/// Runs every task inline; delayed tasks are dropped.
private struct ImmediateDispatcher: TelemetryDispatcher {
    func post(_ task: @escaping @Sendable () -> Void) -> Bool {
        task()
        return true
    }

    func postDelayed(milliseconds: Int64, _ task: @escaping @Sendable () -> Void) -> Bool {
        true
    }
}

/// A fixed, synthetic device context that counts how often it is read.
private final class FakeDeviceContextProvider: DeviceContextProvider, @unchecked Sendable {
    static let attributes = ResourceAttributes(
        serviceVersion: "0.0.0-test",
        deploymentEnvironmentName: "sandbox",
        osVersion: "17.0",
        deviceModelIdentifier: "iPhone15,2",
        appInstallationId: "00000000-0000-4000-8000-000000000001",
        appId: "com.paydock.sample",
        appVersion: "1.0.0",
        appDebuggable: true
    )

    private let lock = NSLock()
    private var calls = 0

    var callCount: Int { lock.withLock { calls } }

    func current() -> ResourceAttributes {
        lock.withLock { calls += 1 }
        return Self.attributes
    }
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
