//
//  ChargesServiceTests.swift
//  DataChargesTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import DataCharges
@testable import NetworkingLib
import CommonModels

final class ChargesServiceTests: XCTestCase {

    func testChargesMockService() async throws {
        let mockService = ChargesMockService()

        let request = InitialiseWalletChargeReq(
            customer: InitialiseWalletChargeCustomer(
                firstName: "John",
                lastName: "Doe",
                email: "john.doe@example.com",
                phone: "+1234567890",
                paymentSource: PaymentSource(
                    type: "apple",
                    refToken: "apple-ref-token"
                )
            ),
            amount: 100.0,
            currency: "AUD",
            reference: "test-ref",
            meta: InitialiseWalletChargeMetaData(
                storeName: "Test Store",
                merchantName: "Test Merchant",
                storeId: "store-123"
            )
        )

        let token = try await mockService.initialiseWalletCharge(
            initializeWalletChargeReq: request,
            apiAccessToken: "test-token"
        )

        XCTAssertEqual(token, "mock-wallet-token-123")

        let captureRequest = CaptureChargeReq(
            amount: "50.00",
            currency: "AUD",
            reference: "test-ref"
        )

        let captureResult = try await mockService.captureCharge(
            request: captureRequest,
            apiAccessToken: "test-token"
        )

        XCTAssertEqual(captureResult.data.id, "mock-charge-789")
        XCTAssertEqual(captureResult.data.amount, 50.0)
    }
}
