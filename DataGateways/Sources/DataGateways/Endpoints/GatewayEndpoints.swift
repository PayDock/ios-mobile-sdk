//
//  GatewayEndpoints.swift
//  DataGateways
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// All `/v1/gateways/*` endpoints
public enum GatewayEndpoints {

    case clientId(gatewayId: String, widgetAccessToken: String)
}

extension GatewayEndpoints: Endpoint {

    public var path: String {
        switch self {
        case .clientId(let gatewayId, _):
            return "/v1/gateways/\(gatewayId)/wallet-config"
        }
    }

    public var method: RequestMethod {
        switch self {
        case .clientId:
            return .get
        }
    }

    public var header: [String: String]? {
        switch self {
        case let .clientId(_, widgetAccessToken):
            return [
                "x-access-token": "\(widgetAccessToken)",
                "Content-Type": "application/json"
            ]
        }
    }

    public var body: Data? {
        switch self {
        case .clientId:
            return nil
        }
    }

    public var parameters: [URLQueryItem] {
        switch self {
        case .clientId:
            return []
        }
    }

    public var mockFile: String? {
        switch self {
        case .clientId:
            return "paypal_vault_get_client_id_success_response"
        }
    }

    public var bundle: Bundle? {
        switch self {
        case .clientId:
//            return Bundle.module
                return nil
        }
    }
}
