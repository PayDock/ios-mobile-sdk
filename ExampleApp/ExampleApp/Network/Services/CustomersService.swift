//
//  CustomersService.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK
import NetworkingLib

protocol CustomersService {

    func createCustomer(request: CreateCustomerTokenReq) async throws -> CreateCustomerTokenRes
}

struct CustomersServiceImpl: HTTPClient, CustomersService {
    
    func createCustomer(request: CreateCustomerTokenReq) async throws -> CreateCustomerTokenRes {
        let response = try await sendRequest(endpoint: CustomersEndpoints.createCustomer(request: request), responseModel: CreateCustomerTokenRes.self)
        return response
    }
}
