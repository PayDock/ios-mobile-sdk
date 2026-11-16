//
//  MobileSDKConfig.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 10.07.2023..
//

import Foundation

public struct MobileSDKConfig {

    var environment: SDKEnvironment
    let theme: Theme?
    let enableTestMode: Bool
    /// The exact Client SDK release every widget loads, in every environment, or `nil` to load the environment's
    /// alias of the supported line: stable in production and sandbox, candidate in staging.
    let clientSdkVersion: String?

    /// Configures the SDK. Widgets load the environment's alias of the supported Client SDK line: stable in production
    /// and sandbox, candidate in staging.
    public init(environment: SDKEnvironment,
                theme: Theme? = nil,
                enableTestMode: Bool = false) {
        self.init(validatedEnvironment: environment, theme: theme, enableTestMode: enableTestMode, clientSdkVersion: nil)
    }

    /// Configures the SDK with a pinned Client SDK release that every widget loads, in every environment, instead of
    /// the environment's alias.
    ///
    /// - Parameter clientSdkVersion: A plain release (`vX.Y.Z`, no `-beta` or other suffix) of the Client SDK line this
    ///   Mobile SDK supports, e.g. `"v1.150.1"`.
    /// - Throws: ``MobileSDKConfigError/clientSdkVersionOutsideSupportedLine(clientSdkVersion:supportedLine:)`` when
    ///   `clientSdkVersion` is not a release of the supported line; its message names the line.
    public init(environment: SDKEnvironment,
                theme: Theme? = nil,
                enableTestMode: Bool = false,
                clientSdkVersion: String) throws {
        let supportedLine = Constants.clientSdkSupportedLine
        guard Self.isRelease(clientSdkVersion, ofLine: supportedLine) else {
            throw MobileSDKConfigError.clientSdkVersionOutsideSupportedLine(clientSdkVersion: clientSdkVersion,
                                                                           supportedLine: supportedLine)
        }
        self.init(validatedEnvironment: environment,
                  theme: theme,
                  enableTestMode: enableTestMode,
                  clientSdkVersion: clientSdkVersion)
    }

    private init(validatedEnvironment environment: SDKEnvironment,
                 theme: Theme?,
                 enableTestMode: Bool,
                 clientSdkVersion: String?) {
        self.environment = environment
        self.theme = theme
        // If the environment is production, force enableTestMode to be false
        // Otherwise, use the value passed in enableTestMode
        self.enableTestMode = (environment == .production) ? false : enableTestMode
        self.clientSdkVersion = clientSdkVersion

        setup()
    }

    /// Whether `version` is a plain release (`vX.Y.Z`) of `line` (`vX.Y`).
    static func isRelease(_ version: String, ofLine line: String) -> Bool {
        let parts = version.split(separator: ".", omittingEmptySubsequences: false)
        guard version.hasPrefix("v"), parts.count == 3,
              parts.allSatisfy({ part in
                  let digits = part.hasPrefix("v") ? part.dropFirst() : part[...]
                  return !digits.isEmpty && digits.allSatisfy { $0.isASCII && $0.isNumber }
              })
        else { return false }
        return "\(parts[0]).\(parts[1])" == line
    }

    private func setup() {
        setupTheme()
    }

    private func setupTheme() {
        guard let theme = theme else { return }
        GlobalTheme.shared.globalTheme = theme
    }
}
