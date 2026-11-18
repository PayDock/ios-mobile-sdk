//
//  TelemetryBindingTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

#if DEBUG
import Foundation
import XCTest
@testable import MobileSDK
import NetworkingLib
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

    /// A temporary stand-in for the app's application-support directory.
    private var applicationSupport = URL(fileURLWithPath: NSTemporaryDirectory())
    private var factory = CountingActiveFactory(applicationSupport: URL(fileURLWithPath: NSTemporaryDirectory()))

    private var telemetryDirectory: URL {
        applicationSupport.appendingPathComponent(FileDurableStore.directoryName, isDirectory: true)
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        applicationSupport = FileManager.default.temporaryDirectory
            .appendingPathComponent("TelemetryBindingTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: applicationSupport, withIntermediateDirectories: true)
        factory = CountingActiveFactory(applicationSupport: applicationSupport)
    }

    override func tearDown() {
        TelemetryBinding.bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
        try? FileManager.default.removeItem(at: applicationSupport)
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

    func testEnvironmentProvider_TheTestRecordVariable() {
        XCTAssertEqual(EnvironmentCredentialsProvider.sendTestRecordKey, "PAYDOCK_TELEMETRY_SEND_TEST_RECORD")
    }

    func testEnvironmentProvider_TheTestCrashVariable() {
        XCTAssertEqual(EnvironmentCredentialsProvider.testCrashKey, "PAYDOCK_TELEMETRY_TEST_CRASH")
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

    /// R_15, MD-36 acceptance: inactive, bound and asked for a test record and a test crash, nothing is created,
    /// written, registered, installed or subscribed: the process's uncaught-exception handler slot is unchanged.
    func testInactive_Bound_CreatesNoDirectory_AndRegistersNothing() throws {
        let handlerBefore = Self.processHandlerAddress()
        for selection in [select(provider: StubCredentialsProvider(value: nil)), select(environment: .production),
                          select(level: .off), select(host: Self.merchantHost)] {
            TelemetryBinding.bind(selection, sendTestRecord: true, raiseTestCrash: true)
            selection.telemetry.report(.widgetOpened(widget: "SampleWidget"))
        }

        XCTAssertEqual(factory.callCount, 0)
        XCTAssertFalse(FileManager.default.fileExists(atPath: telemetryDirectory.path))
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: applicationSupport.path), [])
        XCTAssertEqual(factory.lifecycle.registerCount, 0)
        XCTAssertEqual(factory.connection.startCount, 0)
        XCTAssertEqual(factory.diagnostics.startCount, 0)
        XCTAssertFalse(factory.exceptionHandlers.isInstalled)
        XCTAssertEqual(Self.processHandlerAddress(), handlerBefore)
    }

    /// R_01: inactive, bound with the real `ActiveTelemetry.create` as the factory, no request observer is set:
    /// `NetworkingLib.shared.requestObserver` stays nil.
    func testInactive_Bound_LeavesTheRequestObserverNil() {
        let observerBefore = NetworkingLib.shared.requestObserver
        NetworkingLib.shared.requestObserver = nil
        defer { NetworkingLib.shared.requestObserver = observerBefore }
        let credentials = TelemetryCredentials(endpoint: Self.endpoint, authorization: Self.authorization)
        let inactive = [
            InactiveCondition(provider: StubCredentialsProvider(value: nil)),
            InactiveCondition(provider: StubCredentialsProvider(value: credentials), environment: .production),
            InactiveCondition(provider: StubCredentialsProvider(value: credentials), level: .off),
            InactiveCondition(provider: StubCredentialsProvider(value: credentials), host: Self.merchantHost)
        ]

        for condition in inactive {
            let selection = selectTelemetry(
                credentialsProvider: condition.provider, sdkEnvironment: condition.environment, level: condition.level,
                hostBundleIdentifier: condition.host,
                createActive: { ActiveTelemetry.create(credentials: $0, level: $1, sdkVersion: SDKVersion.current,
                                                       environmentName: condition.environment.rawValue) }
            )
            TelemetryBinding.bind(selection)
            assertNoOp(selection)
        }

        XCTAssertNil(NetworkingLib.shared.requestObserver)
    }

    func testActive_Bound_RegistersTheLifecycleTheMonitorTheHandlerAndTheDiagnosticsOnce() {
        let selection = select()

        TelemetryBinding.bind(selection)
        TelemetryBinding.bind(selection)

        XCTAssertEqual(factory.callCount, 1)
        XCTAssertEqual(factory.lifecycle.registerCount, 1)
        XCTAssertEqual(factory.connection.startCount, 1)
        XCTAssertEqual(factory.diagnostics.startCount, 1)
        XCTAssertTrue(factory.exceptionHandlers.isInstalled)
        XCTAssertEqual(factory.slot.setCount, 1)
    }

    /// R_16: the test record goes to the store directory when active and asked for.
    func testActive_BoundWithTheTestRecord_StoresIt() throws {
        TelemetryBinding.bind(select(), sendTestRecord: true)

        let files = try FileManager.default.contentsOfDirectory(atPath: telemetryDirectory.path)
        XCTAssertEqual(files.count, 1)
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

    func testBind_Active_WithTheTestRecord_SendsItOnce_AfterStart() {
        let runtime = CountingRuntime()

        TelemetryBinding.bind(TelemetrySelection(telemetry: FakeTelemetry(isActive: true), runtime: runtime), sendTestRecord: true)

        XCTAssertEqual(runtime.calls, ["start", "sendTestRecord"])
    }

    /// R_13: the test crash is raised once, after start and the test record, only when active and asked for.
    func testBind_Active_WithTheTestCrash_RaisesItOnce_AfterStart() {
        let runtime = CountingRuntime()

        TelemetryBinding.bind(TelemetrySelection(telemetry: FakeTelemetry(isActive: true), runtime: runtime),
                              sendTestRecord: true, raiseTestCrash: true)

        XCTAssertEqual(runtime.calls, ["start", "sendTestRecord", "raiseTestCrash"])
    }

    func testBind_Active_WithoutTheTestCrash_NeverRaisesIt() {
        let runtime = CountingRuntime()

        TelemetryBinding.bind(TelemetrySelection(telemetry: FakeTelemetry(isActive: true), runtime: runtime),
                              raiseTestCrash: false)

        XCTAssertEqual(runtime.calls, ["start"])
    }

    func testBind_Inactive_WithTheTestCrash_NeverRaisesIt() {
        let runtime = CountingRuntime()

        TelemetryBinding.bind(TelemetrySelection(telemetry: FakeTelemetry(isActive: false), runtime: runtime),
                              raiseTestCrash: true)

        XCTAssertEqual(runtime.calls, [])
    }

    func testBind_ActiveWhileActiveIsBound_NeverRaisesTheSecondsTestCrash() {
        let secondRuntime = CountingRuntime()

        TelemetryBinding.bind(TelemetrySelection(telemetry: FakeTelemetry(isActive: true), runtime: CountingRuntime()))
        TelemetryBinding.bind(TelemetrySelection(telemetry: FakeTelemetry(isActive: true), runtime: secondRuntime),
                              raiseTestCrash: true)

        XCTAssertEqual(secondRuntime.calls, [])
    }

    func testBind_Active_WithoutTheTestRecord_NeverSendsIt() {
        let runtime = CountingRuntime()

        TelemetryBinding.bind(TelemetrySelection(telemetry: FakeTelemetry(isActive: true), runtime: runtime),
                              sendTestRecord: false)

        XCTAssertEqual(runtime.calls, ["start"])
    }

    /// A second `configureMobileSDK` never starts a second runtime on the same store directory.
    func testBind_ActiveWhileActiveIsBound_KeepsTheFirst_AndNeverStartsTheSecond() {
        let first = FakeTelemetry(isActive: true)
        let firstRuntime = CountingRuntime()
        let secondRuntime = CountingRuntime()

        TelemetryBinding.bind(TelemetrySelection(telemetry: first, runtime: firstRuntime))
        let bound = TelemetryBinding.bind(TelemetrySelection(telemetry: FakeTelemetry(isActive: true), runtime: secondRuntime),
                                          sendTestRecord: true)

        XCTAssertTrue((bound as? FakeTelemetry) === first)
        XCTAssertTrue((TelemetryBinding.current as? FakeTelemetry) === first)
        XCTAssertEqual(firstRuntime.calls, ["start"])
        XCTAssertEqual(secondRuntime.calls, [])
    }

    func testBind_InactiveWhileActiveIsBound_ReplacesIt() {
        let inactive = FakeTelemetry(isActive: false)

        TelemetryBinding.bind(TelemetrySelection(telemetry: FakeTelemetry(isActive: true), runtime: CountingRuntime()))
        TelemetryBinding.bind(TelemetrySelection(telemetry: inactive, runtime: CountingRuntime()))

        XCTAssertTrue((TelemetryBinding.current as? FakeTelemetry) === inactive)
    }

    func testBind_Inactive_WithTheTestRecord_NeverSendsIt() {
        let runtime = CountingRuntime()

        TelemetryBinding.bind(TelemetrySelection(telemetry: FakeTelemetry(isActive: false), runtime: runtime), sendTestRecord: true)

        XCTAssertEqual(runtime.calls, [])
    }

    func testBind_Rebinding_ReplacesTheFacade() {
        let first = FakeTelemetry(isActive: false)
        let second = FakeTelemetry(isActive: false)

        TelemetryBinding.bind(TelemetrySelection(telemetry: first, runtime: CountingRuntime()))
        TelemetryBinding.bind(TelemetrySelection(telemetry: second, runtime: CountingRuntime()))

        XCTAssertTrue((TelemetryBinding.current as? FakeTelemetry) === second)
        XCTAssertTrue((MobileSDK.shared.telemetry as? FakeTelemetry) === second)
    }

    /// R_11: with an inactive facade bound, the SDK's reporting calls report nothing.
    func testInactive_Bound_TheSdkCallsReportNothing() async {
        let inactive = RecordingTelemetry(isActive: false)
        TelemetryBinding.bind(TelemetrySelection(telemetry: inactive, runtime: NoOpTelemetry()))

        SdkTelemetry.reportSdkError(SilentFailure.cardExpiryUnreadable, widget: .cardDetails)
        SdkTelemetry.reportUncaught(SampleSwiftError(), widget: .cardDetails)
        SdkTelemetry.reportWidgetOpened(.cardDetails)
        await SdkTask.run(widget: .cardDetails) {
            throw SampleSwiftError()
        }.value

        XCTAssertEqual(inactive.reports, [])
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

    /// The process's uncaught-exception handler, as an address; nil when there is none.
    private static func processHandlerAddress() -> UnsafeRawPointer? {
        NSGetUncaughtExceptionHandler().map { unsafeBitCast($0, to: UnsafeRawPointer.self) }
    }

    private func assertNoOp(_ selection: TelemetrySelection, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(selection.telemetry is NoOpTelemetry, file: file, line: line)
        XCTAssertTrue(selection.runtime is NoOpTelemetry, file: file, line: line)
        XCTAssertFalse(selection.telemetry.isActive, file: file, line: line)
    }
}

/// One way to be inactive; every other condition holds.
private struct InactiveCondition {
    let provider: any TelemetryCredentialsProvider
    var environment: SDKEnvironment = .sandbox
    var level: TelemetryLevel = .all
    var host: String? = "com.paydock.multitenant.sandbox"
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

/// Builds `ActiveTelemetry` with an inline dispatcher, a fixed device context, a file store under the given
/// application-support stand-in, recording lifecycle, monitor and diagnostic source, and a handler chain on a slot of
/// its own (never the process's), and counts its calls.
private final class CountingActiveFactory {
    let provider = FakeDeviceContextProvider()
    let lifecycle = RecordingLifecycle()
    let connection = RecordingConnectionMonitor()
    let diagnostics = CountingDiagnosticSource()
    let slot = CountingHandlerSlot()
    let exceptionHandlers: ExceptionHandlerChain
    private let applicationSupport: URL
    private(set) var arguments: [(credentials: TelemetryCredentials, level: TelemetryLevel)] = []
    private(set) var created: ActiveTelemetry?

    var callCount: Int { arguments.count }

    init(applicationSupport: URL) {
        self.applicationSupport = applicationSupport
        exceptionHandlers = ExceptionHandlerChain(slot: slot, entryPoint: { _ in })
    }

    func make(credentials: TelemetryCredentials, level: TelemetryLevel) -> ActiveTelemetry {
        arguments.append((credentials, level))
        let directory = applicationSupport.appendingPathComponent(FileDurableStore.directoryName, isDirectory: true)
        let telemetry = ActiveTelemetry(
            credentials: credentials,
            level: level,
            deviceContextProvider: provider,
            dispatcher: ImmediateDispatcher(),
            ports: ActiveTelemetry.Ports(store: FileDurableStore(directory: { directory }), lifecycle: lifecycle,
                                         connection: connection, diagnostics: diagnostics,
                                         exceptionHandlers: exceptionHandlers)
        )
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

/// Counts every registration.
private final class RecordingLifecycle: AppLifecycle, @unchecked Sendable {
    private let lock = NSLock()
    private var registrations = 0

    var registerCount: Int { lock.withLock { registrations } }

    func register(onBackground: @escaping @Sendable (_ finished: @escaping @Sendable () -> Void) -> Void) {
        lock.withLock { registrations += 1 }
    }
}

/// Counts every start; the type stays unknown.
private final class RecordingConnectionMonitor: ConnectionMonitor, @unchecked Sendable {
    private let lock = NSLock()
    private var starts = 0

    var startCount: Int { lock.withLock { starts } }

    func start() {
        lock.withLock { starts += 1 }
    }

    func current() -> NetworkConnectionType { .unknown }
}

/// Counts every start; never delivers.
private final class CountingDiagnosticSource: DiagnosticSource, @unchecked Sendable {
    private let lock = NSLock()
    private var starts = 0

    var startCount: Int { lock.withLock { starts } }

    func start(deliver: @escaping @Sendable ([MetricKitDiagnostic]) -> Void) {
        lock.withLock { starts += 1 }
    }
}

/// A handler slot of its own that counts every set.
private final class CountingHandlerSlot: ExceptionHandlerSlot, @unchecked Sendable {
    private let lock = NSLock()
    private var handler: (@convention(c) (NSException) -> Void)?
    private var sets = 0

    var setCount: Int { lock.withLock { sets } }

    func get() -> (@convention(c) (NSException) -> Void)? {
        lock.withLock { handler }
    }

    func set(_ handler: (@convention(c) (NSException) -> Void)?) {
        lock.withLock {
            sets += 1
            self.handler = handler
        }
    }
}

/// Records every call, in order.
private final class CountingRuntime: TelemetryRuntime, @unchecked Sendable {
    private let lock = NSLock()
    private var log: [String] = []

    var calls: [String] { lock.withLock { log } }
    var startCount: Int { calls.filter { $0 == "start" }.count }

    func start() {
        lock.withLock { log.append("start") }
    }

    func sendTestRecord() {
        lock.withLock { log.append("sendTestRecord") }
    }

    func raiseTestCrash() {
        lock.withLock { log.append("raiseTestCrash") }
    }
}
#endif
