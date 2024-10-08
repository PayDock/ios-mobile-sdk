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
    case setupToken(request: PayPalVaultSetupTokenReq, accessToken: String)

}

extension PayPalVaultEndpoints: Endpoint {

    var path: String {
        switch self {
        case .authToken: return "/v1/payment_sources/oauth-tokens"
        case .setupToken: return "/v1/payment_sources/setup-tokens"
        }
    }

    var method: RequestMethod {
        switch self {
        case .authToken: return .post
        case .setupToken: return .post
        }
    }

    var header: [String: String]? {
        switch self {
        case let .authToken(_ , accessToken), let .setupToken(_ , accessToken):
            return [
                "x-access-token": "\(accessToken)",
                "Content-Type": "application/json"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .authToken: return nil
        case .setupToken(let request, _): return try? encoder.encode(request)
        }
    }


    var parameters: [URLQueryItem] {
        switch self {
        case .authToken: return []
        case .setupToken: return []
        }
    }
    
    var mockFile: String? {
        switch self {
        case .authToken: return "paypal_vault_session_auth_success_response"
        case .setupToken: return "paypal_vault_setup_token_success_response"
        }
    }
    
    var bundle: Bundle? {
        return Bundle.module
    }

}
