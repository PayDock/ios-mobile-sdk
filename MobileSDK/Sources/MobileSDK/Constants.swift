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
        case .production: return "https://api.paydock.com"
        case .sandbox: return "https://api-sandbox.paydock.com"
        case .staging: return "https://api-sandbox.paydock.com"
        }
    }
}
