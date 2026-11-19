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
        // A `configureMobileSDK` on sandbox or staging elsewhere in the process binds the collector's runtime.
        TelemetryBinding.bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
    }

    override func tearDown() {
        TelemetryBinding.bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
        try? FileManager.default.removeItem(at: applicationSupport)
        super.tearDown()
    }

    // MARK: - selectTelemetry

    // MARK: - The collector table

    /// R_01: production binds the prod collector; sandbox and staging keep the dev collector.
    func testCollector_ProductionIsTheProdURL_SandboxAndStagingTheDevURL() {
        XCTAssertEqual(TelemetryCollector.prodLogsURL, "https://mobile-telemetry.shared.apac.paydock.com/v1/logs")
        XCTAssertEqual(TelemetryCollector.devLogsURL, "https://mobile-telemetry-dev.shared.apac.paydock.com/v1/logs")
        XCTAssertEqual(TelemetryCollector.logsURL(for: .production), TelemetryCollector.prodLogsURL)
        XCTAssertEqual(TelemetryCollector.logsURL(for: .sandbox), TelemetryCollector.devLogsURL)
        XCTAssertEqual(TelemetryCollector.logsURL(for: .staging), TelemetryCollector.devLogsURL)
    }

    /// R_01: each environment's collector selects the active runtime with that URL as its endpoint.
    func testSelect_EachEnvironmentsCollector_BindsTheActiveRuntime_WithItsURL() throws {
        let expected: [(SDKEnvironment, String)] = [(.production, TelemetryCollector.prodLogsURL),
                                                    (.sandbox, TelemetryCollector.devLogsURL),
                                                    (.staging, TelemetryCollector.devLogsURL)]
        for (environment, url) in expected {
            let selection = select(endpoint: TelemetryCollector.logsURL(for: environment))

            let telemetry = try XCTUnwrap(selection.telemetry as? ActiveTelemetry, environment.rawValue)
            XCTAssertTrue(selection.runtime as? ActiveTelemetry === telemetry, environment.rawValue)
            XCTAssertEqual(telemetry.endpoint, url, environment.rawValue)
        }
        XCTAssertEqual(factory.endpoints, [TelemetryCollector.prodLogsURL, TelemetryCollector.devLogsURL,
                                           TelemetryCollector.devLogsURL])
    }

    /// R_01: a nil, empty or blank URL binds the no-op and creates nothing.
    func testSelect_NilEmptyOrBlankURL_GivesNoOp_AndCreatesNothing() {
        for endpoint in [nil, "", " ", " \n\t "] as [String?] {
            assertNoOp(select(endpoint: endpoint))
        }
        XCTAssertEqual(factory.callCount, 0)
    }

    /// R_15, MD-36 acceptance: inactive and bound, nothing is created, written, registered, installed or subscribed:
    /// the process's uncaught-exception handler slot is unchanged.
    func testInactive_Bound_CreatesNoDirectory_AndRegistersNothing() throws {
        let handlerBefore = Self.processHandlerAddress()
        for selection in [select(endpoint: nil), select(endpoint: " ")] {
            TelemetryBinding.bind(selection)
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
        for endpoint in [nil, "", " "] as [String?] {
            let selection = selectTelemetry(
                endpoint: endpoint,
                createActive: { ActiveTelemetry.create(endpoint: $0, sdkVersion: SDKVersion.current,
                                                       environmentName: SDKEnvironment.production.rawValue) }
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

    func testSelect_EveryConditionHolds_CreatesOnce_AndGivesThatActiveTelemetryAsBothHandles() throws {
        let selection = select()

        XCTAssertEqual(factory.callCount, 1)
        let created = try XCTUnwrap(factory.created)
        let telemetry = try XCTUnwrap(selection.telemetry as? ActiveTelemetry)
        let runtime = try XCTUnwrap(selection.runtime as? ActiveTelemetry)
        XCTAssertTrue(telemetry === created)
        XCTAssertTrue(telemetry === runtime)
        XCTAssertTrue(telemetry.isActive)
        XCTAssertEqual(telemetry.endpoint, Self.endpoint)
    }

    func testSelect_PassesTheEndpointToTheFactory() {
        select()

        XCTAssertEqual(factory.endpoints, [Self.endpoint])
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

    /// A second `configureMobileSDK` never starts a second runtime on the same store directory.
    func testBind_ActiveWhileActiveIsBound_KeepsTheFirst_AndNeverStartsTheSecond() {
        let first = FakeTelemetry(isActive: true)
        let firstRuntime = CountingRuntime()
        let secondRuntime = CountingRuntime()

        TelemetryBinding.bind(TelemetrySelection(telemetry: first, runtime: firstRuntime))
        let bound = TelemetryBinding.bind(TelemetrySelection(telemetry: FakeTelemetry(isActive: true), runtime: secondRuntime))

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
    private func select(endpoint: String? = TelemetryBindingTests.endpoint) -> TelemetrySelection {
        selectTelemetry(endpoint: endpoint, createActive: factory.make)
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
    private(set) var endpoints: [String] = []
    private(set) var created: ActiveTelemetry?

    var callCount: Int { endpoints.count }

    init(applicationSupport: URL) {
        self.applicationSupport = applicationSupport
        exceptionHandlers = ExceptionHandlerChain(slot: slot, entryPoint: { _ in })
    }

    func make(endpoint: String) -> ActiveTelemetry {
        endpoints.append(endpoint)
        let directory = applicationSupport.appendingPathComponent(FileDurableStore.directoryName, isDirectory: true)
        let telemetry = ActiveTelemetry(
            endpoint: endpoint,
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
}
#endif
