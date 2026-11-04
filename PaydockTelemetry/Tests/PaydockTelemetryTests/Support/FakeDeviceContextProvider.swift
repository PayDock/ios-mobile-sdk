//
//  FakeDeviceContextProvider.swift
//  PaydockTelemetryTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import PaydockTelemetry

/// A fixed, synthetic device context that counts how often it is read.
final class FakeDeviceContextProvider: DeviceContextProvider, @unchecked Sendable {
    static let installationId = "00000000-0000-4000-8000-000000000001"

    static let attributes = ResourceAttributes(
        serviceVersion: "0.0.0-test",
        deploymentEnvironmentName: "sandbox",
        osVersion: "17.0",
        deviceModelIdentifier: "iPhone15,2",
        appInstallationId: installationId,
        appId: "com.paydock.sample",
        appVersion: "1.0.0",
        appDebuggable: true
    )

    private let lock = NSLock()
    private var calls = 0

    var callCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return calls
    }

    func current() -> ResourceAttributes {
        lock.lock()
        calls += 1
        lock.unlock()
        return Self.attributes
    }
}
