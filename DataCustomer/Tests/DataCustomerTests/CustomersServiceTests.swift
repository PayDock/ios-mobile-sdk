//
//  CustomersServiceTests.swift
//  DataCustomerTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import DataCustomer
import CommonModels

final class CustomersServiceTests: XCTestCase {

    func testCustomersMockService() async throws {
        let mockService = CustomersMockService()

        let request = CreateCustomerTokenReq(
            token: "vault-token-123",
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@example.com",
            phone: "+1234567890"
        )

        let result = try await mockService.createCustomer(
            request: request,
            apiAccessToken: "test-token"
        )

        XCTAssertEqual(result.status, 201)
        XCTAssertEqual(result.resource.firstName, "John")
        XCTAssertEqual(result.resource.lastName, "Doe")
        XCTAssertEqual(result.resource.email, "john.doe@example.com")
        XCTAssertEqual(result.resource.phone, "+1234567890")
        XCTAssertEqual(result.resource.id, "mock-customer-123")
    }

    func testCustomersMockServiceWithMinimalFields() async throws {
        let mockService = CustomersMockService()

        let request = CreateCustomerTokenReq(token: "vault-token-456")

        let result = try await mockService.createCustomer(
            request: request,
            apiAccessToken: "test-token"
        )

        XCTAssertEqual(result.status, 201)
        XCTAssertEqual(result.resource.id, "mock-customer-123")
        XCTAssertNil(result.resource.firstName)
        XCTAssertNil(result.resource.lastName)
    }
}
