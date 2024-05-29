//
//  Constants.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 10.07.2023..
//

import Foundation

struct Constants {

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

    static var clientSdkUrlString: String {
        guard let environment = MobileSDK.shared.config?.environment else {
            fatalError("Missing configuration!")
        }

        switch environment {
        case .production, .sandbox, .staging: return "https://widget.paydock.com/sdk/latest/widget.umd.min.js"
        }
    }

    static var publicKey: String {
        guard let config = MobileSDK.shared.config else {
            fatalError("Missing configuration!")
        }

        return config.publicKey
    }

    static var payPalCallbackHost: String {
        return "paydock-mobile.sdk"
    }
}
