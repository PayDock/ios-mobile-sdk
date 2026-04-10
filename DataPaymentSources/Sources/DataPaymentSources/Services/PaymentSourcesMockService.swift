//
//  PaymentSourcesMockService.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// Mock service for PaymentSourcesService that returns fake data for testing
public class PaymentSourcesMockService: PaymentSourcesService {

    // MARK: - Test Configuration

    public var shouldReturnError = false
    public var errorToReturn: ErrorRes?
    public var shouldThrowUnknownError = false

    // MARK: - Configurable Results

    public var tokenResult: String?
    public var giftCardTokenResult: String?
    public var applePayTokenResult: String?
    public var setupTokenResult: SetupTokenData?
    public var paymentTokenResult: PaymentTokenData?
    public var externalCheckoutResult: (link: String, checkoutToken: String)?
    public var paymentSourceTokenResult: String?

    public init() {}

    // MARK: - Card & Gift Card Tokens

    public func createToken(
        tokeniseCardDetailsReq: CreatePaymentSourceTokenReq, widgetAccessToken: String
    ) async throws -> String {
        if shouldThrowUnknownError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return tokenResult ?? "mock-payment-source-token-123"
    }

    public func createGiftCardToken(
        tokeniseGiftCardReq: CreateGiftCardTokenReq, widgetAccessToken: String
    ) async throws -> String {
        if shouldThrowUnknownError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return giftCardTokenResult ?? "mock-gift-card-token-456"
    }

    // MARK: - Apple Pay token

    public func createApplePayToken(
        tokeniseApplePayReq: CreateApplePayTokenReq, widgetAccessToken: String
    ) async throws -> String {
        if shouldThrowUnknownError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return applePayTokenResult ?? "mock-apple-pay-ott-token-159"
    }

    // MARK: - PayPal Vault Tokens

    public func createSetupTokenData(
        req: CreatePayPalVaultSetupTokenReq, widgetAccessToken: String
    ) async throws -> SetupTokenData {
        if shouldThrowUnknownError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return setupTokenResult ?? SetupTokenData(setupToken: "mock-setup-token-789")
    }

    public func createPaymentToken(
        request: CreatePayPalVaultPaymentTokenReq,
        setupToken: String,
        widgetAccessToken: String
    ) async throws -> PaymentTokenData {
        if shouldThrowUnknownError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return paymentTokenResult ?? PaymentTokenData(token: "mock-payment-token-321", email: "test@example.com")
    }

    // MARK: - External Checkout (Zip)

    public func initialiseExternalCheckout(
        widgetAccessToken: String, request: CreateExternalCheckoutReq
    ) async throws -> (link: String, checkoutToken: String) {
        if shouldThrowUnknownError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return externalCheckoutResult ?? (
            link: "https://checkout.example.com/mock-checkout-123",
            checkoutToken: "mock-checkout-token-456"
        )
    }

    public func createPaymentSourceToken(
        checkoutToken: String, gatewayId: String, widgetAccessToken: String
    ) async throws -> String {
        if shouldThrowUnknownError {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
        }
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return paymentSourceTokenResult ?? "mock-payment-source-token-from-checkout-789"
    }
}
