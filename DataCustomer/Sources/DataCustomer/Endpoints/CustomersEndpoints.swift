//
//  CustomersEndpoints.swift
//  DataCustomer
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

public enum CustomersEndpoints {

    case createCustomer(request: CreateCustomerTokenReq, apiAccessToken: String)
}

extension CustomersEndpoints: Endpoint {

    public var path: String {
        switch self {
        case .createCustomer: return "/v1/customers"
        }
    }

    public var method: RequestMethod {
        switch self {
        case .createCustomer: return .post
        }
    }

    public var header: [String: String]? {
        let apiAccessToken: String
        switch self {
        case .createCustomer(_, let token):
            apiAccessToken = token
        }
        return [
            "x-access-token": apiAccessToken,
            "Content-Type": "application/json;charset=utf-8"
        ]
    }

    public var body: Data? {
        switch self {
        case .createCustomer(let request, _): return try? encoder.encode(request)
        }
    }

    public var parameters: [URLQueryItem] {
        switch self {
        case .createCustomer: return []
        }
    }

    public var mockFile: String? {
        return nil
    }

    public var bundle: Bundle? {
        return nil
    }
}
