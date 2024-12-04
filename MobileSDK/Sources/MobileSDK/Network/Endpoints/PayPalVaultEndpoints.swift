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

<<<<<<< HEAD
=======
    case authToken(request: PayPalVaultAuthReq, accessToken: String)
>>>>>>> main
    case setupToken(request: PayPalVaultSetupTokenReq, accessToken: String)
    case clientId(gatewayId: String, accessToken: String)
    case paymentToken(setupToken: String, request: PayPalVaultPaymentTokenReq, accessToken: String)

}

extension PayPalVaultEndpoints: Endpoint {

    var path: String {
        switch self {
<<<<<<< HEAD
=======
        case .authToken: return "/v1/payment_sources/oauth-tokens"
>>>>>>> main
        case .setupToken: return "/v1/payment_sources/setup-tokens"
        case .clientId(let gatewayId, _): return "/v1/gateways/\(gatewayId)/wallet-config"
        case .paymentToken(let setupToken, _, _): return "/v1/payment_sources/setup-tokens/\(setupToken)/tokens"
        }
    }

    var method: RequestMethod {
        switch self {
<<<<<<< HEAD
=======
        case .authToken: return .post
>>>>>>> main
        case .setupToken: return .post
        case .clientId: return .get
        case .paymentToken: return .post
        }
    }

    var header: [String: String]? {
        switch self {
<<<<<<< HEAD
        case let .setupToken(_ , accessToken),
=======
        case let .authToken(_ , accessToken),
            let .setupToken(_ , accessToken),
>>>>>>> main
            let .clientId(_, accessToken),
            let .paymentToken(_, _, accessToken):
            return [
                "x-access-token": "\(accessToken)",
                "Content-Type": "application/json"
            ]
        }
    }

    var body: Data? {
        switch self {
<<<<<<< HEAD
=======
        case .authToken(let request, _): return try? encoder.encode(request)
>>>>>>> main
        case .setupToken(let request, _): return try? encoder.encode(request)
        case .clientId: return nil
        case .paymentToken(_, let request, _): return try? encoder.encode(request)
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
<<<<<<< HEAD
=======
        case .authToken: return []
>>>>>>> main
        case .setupToken: return []
        case .clientId: return []
        case .paymentToken: return []
        }
    }
    
    var mockFile: String? {
        switch self {
<<<<<<< HEAD
=======
        case .authToken: return "paypal_vault_session_auth_success_response"
>>>>>>> main
        case .setupToken: return "paypal_vault_setup_token_success_response"
        case .clientId: return "paypal_vault_get_client_id_success_response"
        case .paymentToken: return "paypal_vault_payment_token_success_response"
        }
    }
    
    var bundle: Bundle? {
        return Bundle.module
    }

}
