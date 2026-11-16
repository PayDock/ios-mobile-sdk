//
//  MobileSDKConfigError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

/// Errors in the Mobile SDK configuration itself, thrown by
/// ``MobileSDKConfig/init(environment:theme:enableTestMode:clientSdkVersion:)`` before the SDK is configured.
public enum MobileSDKConfigError: Error, Equatable, WidgetError {
    /// The `clientSdkVersion` pin is not a plain release (`vX.Y.Z`) of the Client SDK line this Mobile SDK supports.
    case clientSdkVersionOutsideSupportedLine(clientSdkVersion: String, supportedLine: String)

    public var customMessage: String {
        switch self {
        case .clientSdkVersionOutsideSupportedLine(let clientSdkVersion, let supportedLine):
            return "clientSdkVersion \(clientSdkVersion) is outside supported line \(supportedLine)"
        }
    }

    public var code: String {
        switch self {
        case .clientSdkVersionOutsideSupportedLine: return "CONFIG_CLIENT_SDK_VERSION_OUTSIDE_SUPPORTED_LINE"
        }
    }

    public var debugDescription: String {
        "\(code): \(customMessage)"
    }
}
