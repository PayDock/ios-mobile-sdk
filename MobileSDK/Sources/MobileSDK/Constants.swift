//
//  Constants.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 10.07.2023..
//

import Foundation

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

    static var sslPublicKeyHash: String {
        guard let environment = MobileSDK.shared.config?.environment else {
            fatalError("Missing configuration!")
        }

        switch environment {
        case .production, .sandbox, .staging: return "g3M/GJUTddzhjBySoIBl4U7M+8j3KgSf1EwPpBIlsHs="
        }
    }

    // MARK: - Client SDK

    static var clientSdkUrlString: String {
        guard let environment = MobileSDK.shared.config?.environment else {
            fatalError("Missing configuration!")
        }

        switch environment {
        case .production, .sandbox, .staging: return "https://widget.paydock.com/sdk/\(clientSdkVersion)/widget.umd.min.js"
        }
    }

    static var clientSdkVersion: String {
        guard let environment = MobileSDK.shared.config?.environment else {
            fatalError("Missing configuration!")
        }

        switch environment {
        case .production: return "v1.108.0"
        case .sandbox, .staging: return "v1.108.0-beta"
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

    static var clientSdkType: String {
        return "paydock"
    }

    // MARK: - Widgets

    static var payPalCallbackHost: String {
        return "paydock-mobile.sdk"
    }
}
