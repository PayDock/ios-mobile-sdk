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
        case .production: return "v1.141.0"
        case .sandbox: return "v1.141.0"
        case .staging: return "v1.141.0-beta"
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
