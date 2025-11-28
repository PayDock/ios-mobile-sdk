//
//  PaymentSourcesServiceMock.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import XCTest
@testable import MobileSDK
@testable import NetworkingLib

class PaymentSourcesServiceMock: Mockable, PaymentSourcesService {

    // MARK: - Card & Gift Card Properties

    var shouldReturnCardError = false
    var cardErrorToReturn: ErrorRes?
    var cardToken = "test_card_token"
    var giftCardToken = "test_gift_card_token"

    // MARK: - PayPal Vault Properties

    var shouldReturnPayPalError = false
    var payPalErrorToReturn: ErrorRes?
    var setupTokenData = PayPalVaultSetupTokenRes.SetupTokenData(
        setupToken: "test_setup_token"
    )
    var paymentTokenData = PayPalVaultPaymentTokenRes.PaymentTokenData(
        token: "test_payment_token",
        email: "test@example.com"
    )

    // MARK: - Zip Properties

    var shouldReturnZipError = false
    var zipRequestErrorToReturn: ErrorRes?
    var shouldThrowUnknownError = false
    var zipCheckoutUrl = "https://test.zip.co/checkout"
    var zipCheckoutToken = "test_checkout_token"

    var shouldReturnZipPaymentTokenError = false
    var zipPaymentTokenErrorToReturn: ErrorRes?
    var shouldThrowPaymentTokenUnknownError = false
    var zipPaymentSourceToken = "test_payment_source_token"

    // MARK: - Card & Gift Card Methods

    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq, accessToken: String) async throws -> String {
        if shouldReturnCardError, let errorRes = cardErrorToReturn {
            throw RequestError.requestError(errorRes)
        }
        return cardToken
    }

    func createGiftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq, accessToken: String) async throws -> String {
        if shouldReturnCardError, let errorRes = cardErrorToReturn {
            throw RequestError.requestError(errorRes)
        }
        return giftCardToken
    }

    // MARK: - PayPal Vault Methods

    func createSetupTokenData(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> PayPalVaultSetupTokenRes.SetupTokenData {
        if shouldReturnPayPalError, let errorRes = payPalErrorToReturn {
            throw RequestError.requestError(errorRes)
        }
        return setupTokenData
    }

    func createPaymentToken(request: PayPalVaultPaymentTokenReq,
                            setupToken: String,
                            accessToken: String) async throws -> PayPalVaultPaymentTokenRes.PaymentTokenData {
        if shouldReturnPayPalError, let errorRes = payPalErrorToReturn {
            throw RequestError.requestError(errorRes)
        }
        return paymentTokenData
    }

    // MARK: - Zip Methods

    func initialiseExternalCheckout(accessToken: String, config: ZipConfig) async throws -> (link: String, checkoutToken: String) {
        if shouldThrowUnknownError {
            throw NSError(domain: "TestError", code: -1, userInfo: nil)
        }

        if shouldReturnZipError, let errorRes = zipRequestErrorToReturn {
            throw RequestError.requestError(errorRes)
        }

        return (link: zipCheckoutUrl, checkoutToken: zipCheckoutToken)
    }

    func createPaymentSourceToken(checkoutToken: String, gatewayId: String, accessToken: String) async throws -> String {
        if shouldThrowPaymentTokenUnknownError {
            throw NSError(domain: "TestError", code: -1, userInfo: nil)
        }

        if shouldReturnZipPaymentTokenError, let errorRes = zipPaymentTokenErrorToReturn {
            throw RequestError.requestError(errorRes)
        }

        return zipPaymentSourceToken
    }
}
