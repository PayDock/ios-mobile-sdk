//
//  TelemetryTestHostTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import XCTest
@testable import MobileSDK
import NetworkingLib
import PaydockTelemetry

/// R_14: a test process never activates telemetry. Compiled and run in every configuration.
final class TelemetryTestHostTests: XCTestCase {

    private static let appBundleIdentifier = "com.paydock.multitenant.sandbox"

    override func tearDown() {
        TelemetryBinding.bind(TelemetrySelection(telemetry: NoOpTelemetry(), runtime: NoOpTelemetry()))
        super.tearDown()
    }

    // MARK: - isTestProcess

    func testTheNames() {
        XCTAssertEqual(TelemetryTestHost.testRunnerBundleIdentifier, "com.apple.dt.xctest.tool")
        XCTAssertEqual(TelemetryTestHost.configurationKey, "XCTestConfigurationFilePath")
    }

    func testTheRunnersBundleIdentifier_IsATestProcess() {
        XCTAssertTrue(TelemetryTestHost.isTestProcess(environment: [:], bundleIdentifier: "com.apple.dt.xctest.tool"))
    }

    func testTheConfigurationKey_IsATestProcess() {
        XCTAssertTrue(TelemetryTestHost.isTestProcess(environment: ["XCTestConfigurationFilePath": "/tmp/run.xctestconfiguration"],
                                                      bundleIdentifier: Self.appBundleIdentifier))
    }

    func testAnAppBundleIdentifier_WithoutTheKey_IsNotATestProcess() {
        XCTAssertFalse(TelemetryTestHost.isTestProcess(environment: ["PATH": "/usr/bin"],
                                                       bundleIdentifier: Self.appBundleIdentifier))
        XCTAssertFalse(TelemetryTestHost.isTestProcess(environment: [:], bundleIdentifier: nil))
    }

    // MARK: - bindTelemetry in a test process

    /// R_14: in every environment, a test process binds the no-op and creates, registers and installs nothing.
    func testBindTelemetry_InATestProcess_BindsTheNoOp_AndCreatesNothing() throws {
        let testProcesses: [(environment: [String: String], bundleIdentifier: String?)] = [
            ([:], TelemetryTestHost.testRunnerBundleIdentifier),
            ([TelemetryTestHost.configurationKey: "/tmp/run.xctestconfiguration"], Self.appBundleIdentifier)
        ]
        let directoryBefore = Self.telemetryDirectoryContents()
        let observerBefore = NetworkingLib.shared.requestObserver.map { ObjectIdentifier($0 as AnyObject) }
        let handlerBefore = Self.processHandlerAddress()

        for process in testProcesses {
            for environment in [SDKEnvironment.sandbox, .staging, .production] {
                let bound = TelemetryBinding.bindTelemetry(environment: environment, processEnvironment: process.environment,
                                                           hostBundleIdentifier: process.bundleIdentifier)

                XCTAssertTrue(bound is NoOpTelemetry, environment.rawValue)
                XCTAssertTrue(TelemetryBinding.current is NoOpTelemetry, environment.rawValue)
            }
        }

        XCTAssertEqual(Self.telemetryDirectoryContents(), directoryBefore)
        XCTAssertEqual(NetworkingLib.shared.requestObserver.map { ObjectIdentifier($0 as AnyObject) }, observerBefore)
        XCTAssertEqual(Self.processHandlerAddress(), handlerBefore)
    }

    /// R_14: `configureMobileSDK` on sandbox, as the other `MobileSDKTests` call it, starts no runtime in this process
    /// and leaves the telemetry directory as it was.
    func testConfigureMobileSDK_OnSandbox_InThisTestProcess_StartsNoRuntime() {
        let directoryBefore = Self.telemetryDirectoryContents()

        MobileSDK.shared.configureMobileSDK(config: MobileSDKConfig(environment: .sandbox))

        XCTAssertTrue(TelemetryBinding.current is NoOpTelemetry)
        XCTAssertFalse(TelemetryBinding.current.isActive)
        XCTAssertEqual(Self.telemetryDirectoryContents(), directoryBefore)
    }

    // MARK: - Helpers

    /// The store's default directory's entries, sorted; nil when the directory does not exist.
    private static func telemetryDirectoryContents() -> [String]? {
        guard let directory = FileDurableStore.defaultDirectory() else {
            return nil
        }
        return FileManager.default.subpaths(atPath: directory.path)?.sorted()
    }

    /// The process's uncaught-exception handler, as an address; nil when there is none.
    private static func processHandlerAddress() -> UnsafeRawPointer? {
        NSGetUncaughtExceptionHandler().map { unsafeBitCast($0, to: UnsafeRawPointer.self) }
    }
}
