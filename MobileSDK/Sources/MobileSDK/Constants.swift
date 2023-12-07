//
//  Constants.swift
//  MobileSDK
//
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

    static var publicKey: String {
        guard let environment = MobileSDK.shared.config?.environment else {
            fatalError("Missing configuration!")
        }

        switch environment {
        case .production: return ""
        case .sandbox: return "b3e5eafcbf585cd298fc66fdc6b449505e64bf8d"
        case .staging: return ""
        }
    }
}
