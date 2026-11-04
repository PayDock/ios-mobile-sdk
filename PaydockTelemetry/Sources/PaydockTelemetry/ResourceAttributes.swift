//
//  ResourceAttributes.swift
//  PaydockTelemetry
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Spec § 5.1, once per batch.
package struct ResourceAttributes: Sendable, Equatable {
    package static let serviceName = "paydock-mobile-sdk"
    package static let serviceNamespace = "paydock"
    package static let sdkPlatform = "ios"
    package static let specVersion = 1
    package static let osName = "iOS"
    package static let deviceManufacturer = "Apple"

    package let serviceVersion: String
    package let deploymentEnvironmentName: String
    package let osVersion: String
    package let deviceModelIdentifier: String
    package let appInstallationId: String
    package let appId: String
    package let appVersion: String
    package let appDebuggable: Bool

    package init(serviceVersion: String, deploymentEnvironmentName: String, osVersion: String,
                 deviceModelIdentifier: String, appInstallationId: String, appId: String, appVersion: String,
                 appDebuggable: Bool) {
        self.serviceVersion = serviceVersion
        self.deploymentEnvironmentName = deploymentEnvironmentName
        self.osVersion = osVersion
        self.deviceModelIdentifier = deviceModelIdentifier
        self.appInstallationId = appInstallationId
        self.appId = appId
        self.appVersion = appVersion
        self.appDebuggable = appDebuggable
    }

    /// The 14 § 5.1 keys: `.int` for spec_version, `.bool` for debuggable, `.string` otherwise.
    package func asMap() -> [String: ResourceAttributeValue] {
        [
            "service.name": .string(Self.serviceName),
            "service.namespace": .string(Self.serviceNamespace),
            "service.version": .string(serviceVersion),
            "paydock.sdk.platform": .string(Self.sdkPlatform),
            "paydock.telemetry.spec_version": .int(Self.specVersion),
            "deployment.environment.name": .string(deploymentEnvironmentName),
            "os.name": .string(Self.osName),
            "os.version": .string(osVersion),
            "device.manufacturer": .string(Self.deviceManufacturer),
            "device.model.identifier": .string(deviceModelIdentifier),
            "app.installation.id": .string(appInstallationId),
            "paydock.app.id": .string(appId),
            "paydock.app.version": .string(appVersion),
            "paydock.app.debuggable": .bool(appDebuggable)
        ]
    }
}
