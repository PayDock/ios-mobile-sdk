//
//  Standalone3dsServiceTests.swift
//  DataStandalone3dsTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import DataStandalone3ds
import CommonModels

final class Standalone3dsServiceTests: XCTestCase {

    func testStandalone3dsMockService() async throws {
        let mockService = Standalone3dsMockService()

        let request = Standalone3DSReq(
            amount: "100.00",
            currency: "AUD",
            reference: "test-ref-123",
            customer: Standalone3DSCustomerPaymentData(
                paymentSource: PaymentSource(
                    type: "card",
                    vaultToken: "vault-token-123",
                    gatewayId: "gateway-456"
                )
            ),
            data: Standalone3DSData(
                serviceId: "service-123",
                authentication: Standalone3DSAuthentication(
                    type: "01",
                    date: "2024-01-01T00:00:00Z",
                    version: "2.2.0",
                    customer: Standalone3DSCustomer(
                        created: "2024-01-01T00:00:00Z",
                        updated: "2024-01-01T00:00:00Z",
                        credsUpdated: "2024-01-01T00:00:00Z",
                        suspicious: false,
                        source: Standalone3DSSource(
                            created: "2024-01-01T00:00:00Z",
                            attempts: [],
                            cardType: "visa"
                        )
                    )
                )
            )
        )

        let token = try await mockService.createStandalone3DSToken(
            request: request,
            apiAccessToken: "test-token"
        )

        XCTAssertEqual(token, "mock-standalone-3ds-token-123")
    }

    func testStandalone3dsMockServiceWithNilToken() async throws {
        // This test verifies the mock service returns a token
        // In real scenarios, the API might return nil in some cases
        let mockService = Standalone3dsMockService()

        let request = Standalone3DSReq(
            amount: "50.00",
            currency: "USD",
            reference: "test-ref-456",
            customer: Standalone3DSCustomerPaymentData(
                paymentSource: PaymentSource(
                    type: "card",
                    vaultToken: "vault-token-456"
                )
            ),
            data: Standalone3DSData(
                serviceId: "service-456",
                authentication: Standalone3DSAuthentication(
                    type: "01",
                    date: "2024-01-01T00:00:00Z",
                    version: "2.2.0",
                    customer: Standalone3DSCustomer(
                        created: "2024-01-01T00:00:00Z",
                        updated: "2024-01-01T00:00:00Z",
                        credsUpdated: "2024-01-01T00:00:00Z",
                        suspicious: false,
                        source: Standalone3DSSource(
                            created: "2024-01-01T00:00:00Z",
                            attempts: ["attempt-1"],
                            cardType: "mastercard"
                        )
                    )
                )
            )
        )

        let token = try await mockService.createStandalone3DSToken(
            request: request,
            apiAccessToken: "test-token"
        )

        XCTAssertNotNil(token)
        XCTAssertEqual(token, "mock-standalone-3ds-token-123")
    }
}
