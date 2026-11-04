//
//  DefaultDeviceContextProvider.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Builds the device context once, on the first `current()`, then returns it. The platform and the installation ID
/// are read only there, so creating the provider reads and writes nothing.
package final class DefaultDeviceContextProvider: DeviceContextProvider, @unchecked Sendable {
    private let platform: any PlatformInfo
    private let installationIds: InstallationIdStore
    private let sdkVersion: String
    private let environmentName: String
    private let lock = NSLock()
    private var cached: ResourceAttributes?

    package init(platform: any PlatformInfo, installationIds: InstallationIdStore, sdkVersion: String,
                 environmentName: String) {
        self.platform = platform
        self.installationIds = installationIds
        self.sdkVersion = sdkVersion
        self.environmentName = environmentName
    }

    package func current() -> ResourceAttributes {
        lock.lock()
        defer { lock.unlock() }
        if let cached {
            return cached
        }
        let attributes = ResourceAttributes(
            serviceVersion: sdkVersion,
            deploymentEnvironmentName: environmentName,
            osVersion: platform.osVersion,
            deviceModelIdentifier: platform.modelIdentifier,
            appInstallationId: installationIds.getOrCreate(),
            appId: platform.appId,
            appVersion: platform.appVersion,
            appDebuggable: platform.appDebuggable
        )
        cached = attributes
        return attributes
    }
}
