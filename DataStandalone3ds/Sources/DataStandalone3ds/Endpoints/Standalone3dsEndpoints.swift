//
//  Standalone3dsEndpoints.swift
//  DataStandalone3ds
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

public enum Standalone3dsEndpoints {

    case standalone3ds(request: Standalone3DSReq, apiAccessToken: String)
}

extension Standalone3dsEndpoints: Endpoint {

    public var path: String {
        switch self {
        case .standalone3ds: return "/v1/charges/standalone-3ds"
        }
    }

    public var method: RequestMethod {
        switch self {
        case .standalone3ds: return .post
        }
    }

    public var header: [String: String]? {
        let apiAccessToken: String
        switch self {
        case .standalone3ds(_, let token):
            apiAccessToken = token
        }
        return [
            "x-access-token": apiAccessToken,
            "Content-Type": "application/json;charset=utf-8"
        ]
    }

    public var body: Data? {
        switch self {
        case .standalone3ds(let request, _): return try? encoder.encode(request)
        }
    }

    public var parameters: [URLQueryItem] {
        switch self {
        case .standalone3ds: return []
        }
    }

    public var mockFile: String? {
        return nil
    }

    public var bundle: Bundle? {
        return nil
    }
}
