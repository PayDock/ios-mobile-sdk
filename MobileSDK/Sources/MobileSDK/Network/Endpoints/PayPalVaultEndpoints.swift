//
//  PayPalVaultEndpoints.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 08.10.2024..
//

import Foundation
import NetworkingLib

enum PayPalVaultEndpoints {

    case authToken(gatewayId: String, accessToken: String)

}

extension PayPalVaultEndpoints: Endpoint {

    var path: String {
        switch self {
        case .authToken: return "/v1/payment_sources/oauth-tokens"
        }
    }

    var method: RequestMethod {
        switch self {
        case .authToken: return .post
        }
    }

    var header: [String: String]? {
        switch self {
        case let .authToken(_ , accessToken):
            return [
                "x-access-token": "\(accessToken)",
                "Content-Type": "application/json"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .authToken: return nil
        }
    }


    var parameters: [URLQueryItem] {
        switch self {
        case .authToken: return []
        }
    }

}
