//
//  CustomersEndpoints.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation
import NetworkingLib

enum CustomersEndpoints {

    case createCustomer(request: CreateCustomerTokenReq)

}

extension CustomersEndpoints: Endpoint {

    var path: String {
        switch self {
        case .createCustomer: return "/v1/customers"
        }
    }

    var method: RequestMethod {
        switch self {
        case .createCustomer: return .post
        }
    }

    var header: [String: String]? {
        let accessToken =  ProjectEnvironment.shared.getAccessToken()
        switch self {
        case .createCustomer:
            return [
                "x-access-token": "\(accessToken)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }

    var body: Data? {
        switch self {
        case let .createCustomer(request): return try? encoder.encode(request)
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        case .createCustomer: return []
        }
    }
    
    var mockFile: String? {
        return nil
    }
    
    var bundle: Bundle? {
        return nil
    }

}
