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

    case authToken(request: PayPalVaultAuthReq, accessToken: String)
    case setupToken(request: PayPalVaultSetupTokenReq, accessToken: String)
    case clientId(gatewayId: String, accessToken: String)
    case paymentToken(request: PayPalVaultPaymentTokenReq, accessToken: String)

}

extension PayPalVaultEndpoints: Endpoint {

    var path: String {
        switch self {
        case .authToken: return "/v1/payment_sources/oauth-tokens"
        case .setupToken: return "/v1/payment_sources/setup-tokens"
        case .clientId(let gatewayId, _): return "/v1/gateways/\(gatewayId)/wallet-config"
        case .paymentToken: return "/v1/payment_sources/tokens"
        }
    }

    var method: RequestMethod {
        switch self {
        case .authToken: return .post
        case .setupToken: return .post
        case .clientId: return .get
        case .paymentToken: return .post
        }
    }

    var header: [String: String]? {
        switch self {
        case let .authToken(_ , accessToken),
            let .setupToken(_ , accessToken),
            let .clientId(_, accessToken),
            let .paymentToken(_, accessToken):
            return [
                "x-access-token": "\(accessToken)",
                "Content-Type": "application/json"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .authToken(let request, _): return try? encoder.encode(request)
        case .setupToken(let request, _): return try? encoder.encode(request)
        case .clientId: return nil
        case .paymentToken(let request, _): return try? encoder.encode(request)
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        case .authToken: return []
        case .setupToken: return []
        case .clientId: return []
        case .paymentToken: return []
        }
    }
    
    var mockFile: String? {
        switch self {
        case .authToken: return "paypal_vault_session_auth_success_response"
        case .setupToken: return "paypal_vault_setup_token_success_response"
        case .clientId: return "paypal_vault_get_client_id_success_response"
        case .paymentToken: return "paypal_vault_payment_token_success_response"
        }
    }
    
    var bundle: Bundle? {
        return Bundle.module
    }

}
