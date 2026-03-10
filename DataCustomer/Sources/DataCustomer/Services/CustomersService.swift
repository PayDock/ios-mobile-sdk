//
//  CustomersService.swift
//  DataCustomer
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

public protocol CustomersService {
    func createCustomer(request: CreateCustomerTokenReq, apiAccessToken: String) async throws -> CreateCustomerTokenRes
}

public struct CustomersServiceImpl: HTTPClient, CustomersService {

    public init() {}

    public func createCustomer(request: CreateCustomerTokenReq, apiAccessToken: String) async throws -> CreateCustomerTokenRes {
        let endpoint = CustomersEndpoints.createCustomer(request: request, apiAccessToken: apiAccessToken)
        let response = try await sendRequest(
            endpoint: endpoint,
            responseModel: CreateCustomerTokenRes.self,
            timeout: 60)
        return response
    }
}
