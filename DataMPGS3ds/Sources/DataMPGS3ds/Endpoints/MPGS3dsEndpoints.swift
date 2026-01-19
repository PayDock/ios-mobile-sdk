//
//  MPGS3dsEndpoints.swift
//  DataMPGS3ds
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

public enum MPGS3dsEndpoints {

    case mpgs3ds(request: MPGS3dsReq, apiAccessToken: String)
    case mpgs3dsVault(request: MPGS3dsVaultReq, apiAccessToken: String)
}

extension MPGS3dsEndpoints: Endpoint {

    public var path: String {
        switch self {
        case .mpgs3ds, .mpgs3dsVault: return "/v1/charges/3ds"
        }
    }

    public var method: RequestMethod {
        switch self {
        case .mpgs3ds, .mpgs3dsVault: return .post
        }
    }

    public var header: [String: String]? {
        let apiAccessToken: String
        switch self {
        case .mpgs3ds(_, let token), .mpgs3dsVault(_, let token):
            apiAccessToken = token
        }
        return [
            "x-access-token": apiAccessToken,
            "Content-Type": "application/json;charset=utf-8"
        ]
    }

    public var body: Data? {
        switch self {
        case .mpgs3ds(let request, _): return try? encoder.encode(request)
        case .mpgs3dsVault(let request, _): return try? encoder.encode(request)
        }
    }

    public var parameters: [URLQueryItem] {
        switch self {
        case .mpgs3ds, .mpgs3dsVault: return []
        }
    }

    public var mockFile: String? {
        return nil
    }

    public var bundle: Bundle? {
        return nil
    }
}
