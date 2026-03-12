//
//  VaultEndpoints.swift
//  DataVault
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

public enum VaultEndpoints {

    case vaultToken(request: ConvertToVaultTokenReq, apiAccessToken: String)
    case convertToVaultToken(request: ConvertToVaultTokenReq, apiAccessToken: String)
}

extension VaultEndpoints: Endpoint {

    public var path: String {
        switch self {
        case .vaultToken, .convertToVaultToken: return "/v1/vault/payment_sources"
        }
    }

    public var method: RequestMethod {
        switch self {
        case .vaultToken, .convertToVaultToken: return .post
        }
    }

    public var header: [String: String]? {
        let apiAccessToken: String
        switch self {
        case .vaultToken(_, let token), .convertToVaultToken(_, let token):
            apiAccessToken = token
        }
        return [
            "x-access-token": apiAccessToken,
            "Content-Type": "application/json;charset=utf-8"
        ]
    }

    public var body: Data? {
        switch self {
        case .vaultToken(let request, _): return try? encoder.encode(request)
        case .convertToVaultToken(let request, _): return try? encoder.encode(request)
        }
    }

    public var parameters: [URLQueryItem] {
        switch self {
        case .vaultToken, .convertToVaultToken: return []
        }
    }

    public var mockFile: String? {
        return nil
    }

    public var bundle: Bundle? {
        return nil
    }
}
