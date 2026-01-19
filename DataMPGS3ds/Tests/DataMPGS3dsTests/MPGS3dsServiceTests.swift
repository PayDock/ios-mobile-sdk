//
//  MPGS3dsServiceTests.swift
//  DataMPGS3dsTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import DataMPGS3ds
import CommonModels

final class MPGS3dsServiceTests: XCTestCase {

    func testMPGS3dsMockServiceCreateToken() async throws {
        let mockService = MPGS3dsMockService()

        let request = MPGS3dsReq(
            amount: "100.00",
            currency: "AUD",
            reference: "test-ref",
            threeDS: MPGS3dsData(
                browserDetails: MPGS3dsBrowserDetails()
            ),
            token: "payment-token-123"
        )

        let token = try await mockService.createMPGS3dsToken(
            request: request,
            apiAccessToken: "test-token"
        )

        XCTAssertEqual(token, "mock-mpgs-3ds-token-123")
    }

    func testMPGS3dsMockServiceCreateVaultToken() async throws {
        let mockService = MPGS3dsMockService()

        let customer = Customer(
            firstName: "John",
            lastName: "Doe",
            paymentSource: PaymentSource(
                vaultToken: "vault-token-123",
                gatewayId: "gateway-123"
            )
        )

        let request = MPGS3dsVaultReq(
            amount: "50.00",
            currency: "AUD",
            reference: "test-vault-ref",
            customer: customer,
            threeDS: MPGS3dsData(
                browserDetails: MPGS3dsBrowserDetails()
            )
        )

        let result = try await mockService.createMPGS3dsVaultToken(
            request: request,
            apiAccessToken: "test-token"
        )

        XCTAssertEqual(result.status, 201)
        XCTAssertEqual(result.resource.data.id, "mock-mpgs-charge-123")
        XCTAssertEqual(result.resource.data.amount, 50.0)
        XCTAssertEqual(result.resource.data.currency, "AUD")
        XCTAssertEqual(result.resource.data.status, "pre_authentication_pending")
        XCTAssertEqual(result.resource.data.threeDS.token, "mock-mpgs-3ds-token-456")
    }
}
