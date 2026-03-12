//
//  PaymentSourcesServiceTests.swift
//  DataPaymentSourcesTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import DataPaymentSources
import CommonModels

final class PaymentSourcesServiceTests: XCTestCase {

    func testPaymentSourcesMockServiceCreateToken() async throws {
        let mockService = PaymentSourcesMockService()

        let request = CreatePaymentSourceTokenReq(
            gatewayId: "gateway-123",
            cardNumber: "5123450000000008",
            cardName: "John Doe",
            expireMonth: "12",
            expireYear: "25",
            cardCcv: "123",
            storeCcv: true
        )

        let token = try await mockService.createToken(
            tokeniseCardDetailsReq: request,
            widgetAccessToken: "test-token"
        )

        XCTAssertEqual(token, "mock-payment-source-token-123")
    }

    func testPaymentSourcesMockServiceCreateGiftCardToken() async throws {
        let mockService = PaymentSourcesMockService()

        let request = CreateGiftCardTokenReq(
            cardNumber: "1234567890123456",
            cardPin: "1234",
            storePin: false
        )

        let token = try await mockService.createGiftCardToken(
            tokeniseGiftCardReq: request,
            widgetAccessToken: "test-token"
        )

        XCTAssertEqual(token, "mock-gift-card-token-456")
    }

    func testPaymentSourcesMockServiceCreateSetupToken() async throws {
        let mockService = PaymentSourcesMockService()

        let request = CreatePayPalVaultSetupTokenReq(
            gatewayId: "gateway-789",
            returnUrl: "https://example.com/return",
            cancelUrl: "https://example.com/cancel"
        )

        let setupTokenData = try await mockService.createSetupTokenData(
            req: request,
            widgetAccessToken: "test-token"
        )

        XCTAssertEqual(setupTokenData.setupToken, "mock-setup-token-789")
    }

    func testPaymentSourcesMockServiceCreatePaymentToken() async throws {
        let mockService = PaymentSourcesMockService()

        let request = CreatePayPalVaultPaymentTokenReq(
            gatewayId: "gateway-123"
        )

        let paymentTokenData = try await mockService.createPaymentToken(
            request: request,
            setupToken: "setup-token-456",
            widgetAccessToken: "test-token"
        )

        XCTAssertEqual(paymentTokenData.token, "mock-payment-token-321")
        XCTAssertEqual(paymentTokenData.email, "test@example.com")
    }

    func testPaymentSourcesMockServiceInitialiseExternalCheckout() async throws {
        let mockService = PaymentSourcesMockService()

        let request = CreateExternalCheckoutReq(
            gatewayId: "gateway-123",
            meta: ExternalCheckoutMeta(
                firstName: "John",
                lastName: "Doe",
                email: "john.doe@example.com"
            ),
            successRedirectUrl: "https://example.com/success",
            errorRedirectUrl: "https://example.com/error",
            redirectUrl: "https://example.com/redirect"
        )

        let result = try await mockService.initialiseExternalCheckout(
            widgetAccessToken: "test-token",
            request: request
        )

        XCTAssertEqual(result.link, "https://checkout.example.com/mock-checkout-123")
        XCTAssertEqual(result.checkoutToken, "mock-checkout-token-456")
    }

    func testPaymentSourcesMockServiceCreatePaymentSourceTokenFromCheckout() async throws {
        let mockService = PaymentSourcesMockService()

        let token = try await mockService.createPaymentSourceToken(
            checkoutToken: "checkout-token-123",
            gatewayId: "gateway-456",
            widgetAccessToken: "test-token"
        )

        XCTAssertEqual(token, "mock-payment-source-token-from-checkout-789")
    }
}
