//
//  CustomersMockService.swift
//  DataCustomer
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import CommonModels

/// Mock service for CustomersService that returns fake data for testing
public struct CustomersMockService: CustomersService {

    public init() {}

    public func createCustomer(request: CreateCustomerTokenReq, apiAccessToken: String) async throws -> CreateCustomerTokenRes {
        return CreateCustomerTokenRes(
            status: 201,
            resource: Customer(
                firstName: request.firstName,
                lastName: request.lastName,
                email: request.email,
                phone: request.phone,
                paymentSource: request.paymentSource,
                id: "mock-customer-123",
                externalId: request.externalId,
                suspicious: request.suspicious,
                updatedAt: "2024-01-01T00:00:00Z",
                createdAt: "2024-01-01T00:00:00Z"
            )
        )
    }
}
