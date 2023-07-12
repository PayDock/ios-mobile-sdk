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
            print("Missing configuration!")
            return ""
        }
        
        switch environment {
        case .production: return "api.paydock.com"
        case .sandbox: return "api-sandbox.paydock.com"
        case .staging: return "apista.paydock.com"
        }
    }
}
