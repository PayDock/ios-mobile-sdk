//
//  GatewayEndpoints.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.

import Foundation
import NetworkingLib

/// All `/v1/gateways/*` endpoints
enum GatewayEndpoints {

    case clientId(gatewayId: String, accessToken: String)
}

extension GatewayEndpoints: Endpoint {

    var path: String {
        switch self {
        case .clientId(let gatewayId, _):
            return "/v1/gateways/\(gatewayId)/wallet-config"
        }
    }

    var method: RequestMethod {
        switch self {
        case .clientId:
            return .get
        }
    }

    var header: [String: String]? {
        switch self {
        case let .clientId(_, accessToken):
            return [
                "x-access-token": "\(accessToken)",
                "Content-Type": "application/json"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .clientId:
            return nil
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        case .clientId:
            return []
        }
    }

    var mockFile: String? {
        switch self {
        case .clientId:
            return "paypal_vault_get_client_id_success_response"
        }
    }

    var bundle: Bundle? {
        return Bundle.module
    }
}
