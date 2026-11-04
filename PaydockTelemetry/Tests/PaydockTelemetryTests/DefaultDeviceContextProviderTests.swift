//
//  DefaultDeviceContextProviderTests.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import PaydockTelemetry
import XCTest

final class DefaultDeviceContextProviderTests: XCTestCase {

    private let platform = FakePlatformInfo()
    private let store = InMemoryKeyValueStore()

    func testCurrent_MapsThePlatformTheInstallationIdTheVersionAndTheEnvironment() {
        let attributes = makeProvider().current()

        XCTAssertEqual(attributes, ResourceAttributes(
            serviceVersion: "4.9.1",
            deploymentEnvironmentName: "sandbox",
            osVersion: "17.4.1",
            deviceModelIdentifier: "iPhone15,2",
            appInstallationId: "install-0",
            appId: "com.paydock.sample",
            appVersion: "2.3.0",
            appDebuggable: true
        ))
    }

    func testCurrent_ReadsThePlatformAndTheIdStoreOnce_AcrossManyCalls() {
        let provider = makeProvider()

        let results = (0..<10).map { _ in provider.current() }

        XCTAssertEqual(Set(results.map(\.appInstallationId)), ["install-0"])
        XCTAssertEqual(platform.readCounts, [
            "osVersion": 1, "modelIdentifier": 1, "appId": 1, "appVersion": 1, "appDebuggable": 1
        ])
        XCTAssertEqual(store.readCount, 1)
        XCTAssertEqual(store.writeCount, 1)
    }

    func testCurrent_FromManyThreads_BuildsOnce() {
        let provider = makeProvider()

        DispatchQueue.concurrentPerform(iterations: 50) { _ in _ = provider.current() }

        XCTAssertEqual(platform.readCounts["osVersion"], 1)
        XCTAssertEqual(store.readCount, 1)
    }

    func testInit_ReadsAndWritesNothing() {
        _ = makeProvider()

        XCTAssertTrue(platform.readCounts.isEmpty)
        XCTAssertEqual(store.readCount, 0)
        XCTAssertEqual(store.writeCount, 0)
    }

    private func makeProvider() -> DefaultDeviceContextProvider {
        DefaultDeviceContextProvider(
            platform: platform,
            installationIds: InstallationIdStore(store: store, idGenerator: SequentialIdGenerator(prefix: "install")),
            sdkVersion: "4.9.1",
            environmentName: "sandbox"
        )
    }
}
