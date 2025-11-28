//
//  PaymentSourcesService.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.

import Foundation
import NetworkingLib

/// Service for all `/v1/payment_sources/*` endpoints
protocol PaymentSourcesService {

    // MARK: - Card & Gift Card Tokens

    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq, accessToken: String) async throws -> String
    func createGiftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq, accessToken: String) async throws -> String

    // MARK: - PayPal Vault Tokens

    func createSetupTokenData(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> PayPalVaultSetupTokenRes.SetupTokenData
    func createPaymentToken(request: PayPalVaultPaymentTokenReq,
                            setupToken: String,
                            accessToken: String) async throws -> PayPalVaultPaymentTokenRes.PaymentTokenData

    // MARK: - External Checkout (Zip)

    func initialiseExternalCheckout(accessToken: String, config: ZipConfig) async throws -> (link: String, checkoutToken: String)
    func createPaymentSourceToken(checkoutToken: String, gatewayId: String, accessToken: String) async throws -> String
}

// MARK: - PaymentSourcesServiceImpl

struct PaymentSourcesServiceImpl: HTTPClient, PaymentSourcesService {

    // MARK: - Card & Gift Card Tokens

    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(
            endpoint: PaymentSourcesEndpoints.cardToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq, accessToken: accessToken),
            responseModel: CardTokenRes.self)
        return response.resource.data
    }

    func createGiftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(
            endpoint: PaymentSourcesEndpoints.giftCardToken(tokeniseGiftCardReq: tokeniseGiftCardReq, accessToken: accessToken),
            responseModel: CardTokenRes.self)
        return response.resource.data
    }

    // MARK: - PayPal Vault Tokens

    func createSetupTokenData(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> PayPalVaultSetupTokenRes.SetupTokenData {
        let response = try await sendRequest(
            endpoint: PaymentSourcesEndpoints.setupToken(request: req, accessToken: accessToken),
            responseModel: PayPalVaultSetupTokenRes.self)
        return response.resource.data
    }

    func createPaymentToken(request: PayPalVaultPaymentTokenReq,
                            setupToken: String,
                            accessToken: String) async throws -> PayPalVaultPaymentTokenRes.PaymentTokenData {
        let response = try await sendRequest(
            endpoint: PaymentSourcesEndpoints.paymentToken(setupToken: setupToken, request: request, accessToken: accessToken),
            responseModel: PayPalVaultPaymentTokenRes.self)
        return response.resource.data
    }

    // MARK: - External Checkout (Zip)

    func initialiseExternalCheckout(accessToken: String, config: ZipConfig) async throws -> (link: String, checkoutToken: String) {
        let externalCheckoutReq = ExternalCheckoutReq(
            gatewayId: config.gatewayId,
            meta: ExternalCheckoutMeta(firstName: config.shopper.firstName,
                                       lastName: config.shopper.lastName,
                                       email: config.shopper.email,
                                       tokenize: true,
                                       charge: ExternalCheckoutCharge(amount: Double(truncating: config.amount as NSNumber),
                                                                      currency: config.currency,
                                                                      billingAddress: ExternalBillingAddress(
                                                                        firstName: config.billing?.firstName,
                                                                        lastName: config.billing?.lastName,
                                                                        addressLine1: config.billing?.line1,
                                                                        addressCity: config.billing?.city,
                                                                        addressState: config.billing?.state,
                                                                        addressCountry: config.billing?.countryCode,
                                                                        addressPostcode: config.billing?.postalCode))),
            successRedirectUrl: Constants.zipRedirectUrl,
            errorRedirectUrl: Constants.zipRedirectUrl,
            redirectUrl: Constants.zipRedirectUrl)

        let endpoint = PaymentSourcesEndpoints.externalCheckout(accessToken: accessToken, request: externalCheckoutReq)
        let response = try await sendRequest(endpoint: endpoint, responseModel: ExternalCheckoutRes.self)

        return (link: response.resource.data.link, checkoutToken: response.resource.data.token)
    }

    func createPaymentSourceToken(checkoutToken: String, gatewayId: String, accessToken: String) async throws -> String {
        let request = PaymentSourceTokenReq(checkoutToken: checkoutToken, gatewayId: gatewayId)
        let endpoint = PaymentSourcesEndpoints.zipToken(request: request, accessToken: accessToken)
        let response = try await sendRequest(endpoint: endpoint, responseModel: CardTokenRes.self)
        return response.resource.data
    }
}

// MARK: - PaymentSourcesMockServiceImpl

struct PaymentSourcesMockServiceImpl: MockHTTPClient, PaymentSourcesService {

    // MARK: - Card & Gift Card Tokens

    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(
            endpoint: PaymentSourcesEndpoints.cardToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq, accessToken: accessToken),
            responseModel: CardTokenRes.self)
        return response.resource.data
    }

    func createGiftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(
            endpoint: PaymentSourcesEndpoints.giftCardToken(tokeniseGiftCardReq: tokeniseGiftCardReq, accessToken: accessToken),
            responseModel: CardTokenRes.self)
        return response.resource.data
    }

    // MARK: - PayPal Vault Tokens

    func createSetupTokenData(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> PayPalVaultSetupTokenRes.SetupTokenData {
        let response = try await sendRequest(
            endpoint: PaymentSourcesEndpoints.setupToken(request: req, accessToken: accessToken),
            responseModel: PayPalVaultSetupTokenRes.self)
        return response.resource.data
    }

    func createPaymentToken(request: PayPalVaultPaymentTokenReq,
                            setupToken: String,
                            accessToken: String) async throws -> PayPalVaultPaymentTokenRes.PaymentTokenData {
        let response = try await sendRequest(
            endpoint: PaymentSourcesEndpoints.paymentToken(setupToken: setupToken, request: request, accessToken: accessToken),
            responseModel: PayPalVaultPaymentTokenRes.self)
        return response.resource.data
    }

    // MARK: - External Checkout (Zip)

    func initialiseExternalCheckout(accessToken: String, config: ZipConfig) async throws -> (link: String, checkoutToken: String) {
        let externalCheckoutReq = ExternalCheckoutReq(
            gatewayId: config.gatewayId,
            meta: ExternalCheckoutMeta(firstName: config.shopper.firstName,
                                       lastName: config.shopper.lastName,
                                       email: config.shopper.email,
                                       tokenize: true,
                                       charge: ExternalCheckoutCharge(amount: Double(truncating: config.amount as NSNumber),
                                                                      currency: config.currency,
                                                                      billingAddress: ExternalBillingAddress(
                                                                        firstName: config.billing?.firstName,
                                                                        lastName: config.billing?.lastName,
                                                                        addressLine1: config.billing?.line1,
                                                                        addressCity: config.billing?.city,
                                                                        addressState: config.billing?.state,
                                                                        addressCountry: config.billing?.countryCode,
                                                                        addressPostcode: config.billing?.postalCode))),
            successRedirectUrl: Constants.zipRedirectUrl,
            errorRedirectUrl: Constants.zipRedirectUrl,
            redirectUrl: Constants.zipRedirectUrl)

        let endpoint = PaymentSourcesEndpoints.externalCheckout(accessToken: accessToken, request: externalCheckoutReq)
        let response = try await sendRequest(endpoint: endpoint, responseModel: ExternalCheckoutRes.self)

        return (link: response.resource.data.link, checkoutToken: response.resource.data.token)
    }

    func createPaymentSourceToken(checkoutToken: String, gatewayId: String, accessToken: String) async throws -> String {
        let request = PaymentSourceTokenReq(checkoutToken: checkoutToken, gatewayId: gatewayId)
        let endpoint = PaymentSourcesEndpoints.zipToken(request: request, accessToken: accessToken)
        let response = try await sendRequest(endpoint: endpoint, responseModel: CardTokenRes.self)
        return response.resource.data
    }
}
