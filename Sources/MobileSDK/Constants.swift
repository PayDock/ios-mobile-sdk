//
//  Constants.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 10.07.2023..
//

import Foundation
import CorePayments

struct Constants {

    // MARK: - Main

    static var baseURL: String {
        guard let environment = MobileSDK.shared.config?.environment else {
            fatalError("Missing configuration!")
        }

        switch environment {
        case .production: return "api.paydock.com"
        case .sandbox: return "api-sandbox.paydock.com"
        case .staging: return "apista.paydock.com"
        }
    }

    // MARK: - Client SDK

    /// The Client SDK version line (`vX.Y`) this Mobile SDK release supports. Without a pin, widgets load this line's
    /// stable alias in production and sandbox, so sandbox runs exactly what production runs, and its candidate alias in
    /// staging, so the next release of the line is exercised before it is promoted. The release alias check
    /// (`scripts/check-client-sdk-aliases.sh`) reads the line from this declaration.
    static let clientSdkSupportedLine = "v1.150"

    /// The supported line's stable alias: the production and sandbox default.
    static let clientSdkStableVersion = "\(clientSdkSupportedLine).stable"

    /// The supported line's candidate alias: the staging default.
    static let clientSdkCandidateVersion = "\(clientSdkSupportedLine).candidate"

    static var clientSdkUrlString: String {
        clientSdkUrlString(version: clientSdkVersion)
    }

    /// Address of the Client SDK script for an exact release (`vX.Y.Z`) or an alias of a line (`vX.Y.stable`,
    /// `vX.Y.candidate`).
    static func clientSdkUrlString(version: String) -> String {
        "https://widget.paydock.com/sdk/\(version)/widget.umd.min.js"
    }

    /// The configured pin, or the environment's alias of the supported line.
    static var clientSdkVersion: String {
        guard let config = MobileSDK.shared.config else {
            fatalError("Missing configuration!")
        }
        return clientSdkVersion(environment: config.environment, pin: config.clientSdkVersion)
    }

    /// The pin when set, else the stable alias in production and sandbox and the candidate alias in staging.
    static func clientSdkVersion(environment: SDKEnvironment, pin: String?) -> String {
        if let pin { return pin }
        switch environment {
        case .production, .sandbox: return clientSdkStableVersion
        case .staging: return clientSdkCandidateVersion
        }
    }

    static var clientSdkEnvironment: String {
        guard let environment = MobileSDK.shared.config?.environment else {
            fatalError("Missing configuration!")
        }

        switch environment {
        case .production: return "production"
        case .sandbox: return "sandbox"
        case .staging: return "staging"
        }
    }

    static var payPalEnvironment: CorePayments.Environment {
        guard let environment = MobileSDK.shared.config?.environment else {
            fatalError("Missing configuration!")
        }

        switch environment {
        case .production: return CorePayments.Environment.live
        case .sandbox, .staging: return CorePayments.Environment.sandbox
        }
    }

    static var clientSdkType: String {
        return "paydock"
    }

    // MARK: - Widgets

    static var payPalCallbackHost: String {
        return "paydock.com"
    }

    static var zipCallbackHost: String {
        return "paydock.com"
    }

    static var zipRedirectUrl: String {
        return "https://paydock.com/zip/response"
    }
}
