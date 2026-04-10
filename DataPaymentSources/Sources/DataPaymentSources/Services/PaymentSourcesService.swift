//
//  PaymentSourcesService.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// Service for all `/v1/payment_sources/*` endpoints
public protocol PaymentSourcesService {

    // MARK: - Card & Gift Card Tokens

    func createToken(tokeniseCardDetailsReq: CreatePaymentSourceTokenReq, widgetAccessToken: String) async throws -> String
    func createGiftCardToken(tokeniseGiftCardReq: CreateGiftCardTokenReq, widgetAccessToken: String) async throws -> String

    // MARK: - Apple Pay token

    func createApplePayToken(tokeniseApplePayReq: CreateApplePayTokenReq, widgetAccessToken: String) async throws -> String

    // MARK: - PayPal Vault Tokens

    func createSetupTokenData(req: CreatePayPalVaultSetupTokenReq, widgetAccessToken: String) async throws -> SetupTokenData
    func createPaymentToken(request: CreatePayPalVaultPaymentTokenReq,
                            setupToken: String,
                            widgetAccessToken: String) async throws -> PaymentTokenData

    // MARK: - External Checkout (Zip)

    func initialiseExternalCheckout(
        widgetAccessToken: String,
        request: CreateExternalCheckoutReq
    ) async throws -> (link: String, checkoutToken: String)
    func createPaymentSourceToken(checkoutToken: String, gatewayId: String, widgetAccessToken: String) async throws -> String
}

// MARK: - PaymentSourcesServiceImpl

public struct PaymentSourcesServiceImpl: HTTPClient, PaymentSourcesService {

    public init() {}

    // MARK: - Card & Gift Card Tokens

    public func createToken(tokeniseCardDetailsReq: CreatePaymentSourceTokenReq, widgetAccessToken: String) async throws -> String {
        let endpoint = PaymentSourcesEndpoints.cardToken(
            tokeniseCardDetailsReq: tokeniseCardDetailsReq,
            widgetAccessToken: widgetAccessToken
        )
        let response = try await sendRequest(endpoint: endpoint, responseModel: PaymentSourceTokenRes.self, timeout: 60)
        return response.resource.data
    }

    public func createGiftCardToken(tokeniseGiftCardReq: CreateGiftCardTokenReq, widgetAccessToken: String) async throws -> String {
        let response = try await sendRequest(
            endpoint: PaymentSourcesEndpoints.giftCardToken(tokeniseGiftCardReq: tokeniseGiftCardReq, widgetAccessToken: widgetAccessToken),
            responseModel: PaymentSourceTokenRes.self,
            timeout: 60)
        return response.resource.data
    }

    // MARK: - Apple Pay token

    public func createApplePayToken(tokeniseApplePayReq: CreateApplePayTokenReq, widgetAccessToken: String) async throws -> String {
        let response = try await sendRequest(
            endpoint: PaymentSourcesEndpoints.applePayToken(tokeniseApplePayReq: tokeniseApplePayReq, widgetAccessToken: widgetAccessToken),
            responseModel: ApplePayTokenRes.self)
        return response.resource.data.tempToken
    }

    // MARK: - PayPal Vault Tokens

    public func createSetupTokenData(req: CreatePayPalVaultSetupTokenReq, widgetAccessToken: String) async throws -> SetupTokenData {
        let response = try await sendRequest(
            endpoint: PaymentSourcesEndpoints.setupToken(request: req, widgetAccessToken: widgetAccessToken),
            responseModel: PayPalVaultSetupTokenRes.self,
            timeout: 60)
        return response.resource.data
    }

    public func createPaymentToken(request: CreatePayPalVaultPaymentTokenReq,
                                   setupToken: String,
                                   widgetAccessToken: String) async throws -> PaymentTokenData {
        let response = try await sendRequest(
            endpoint: PaymentSourcesEndpoints.paymentToken(setupToken: setupToken, request: request, widgetAccessToken: widgetAccessToken),
            responseModel: PayPalVaultPaymentTokenRes.self,
            timeout: 60)
        return response.resource.data
    }

    // MARK: - External Checkout (Zip)

    public func initialiseExternalCheckout(
        widgetAccessToken: String,
        request: CreateExternalCheckoutReq
    ) async throws -> (link: String, checkoutToken: String) {
        let endpoint = PaymentSourcesEndpoints.externalCheckout(
            request: request,
            widgetAccessToken: widgetAccessToken
        )
        let response = try await sendRequest(endpoint: endpoint, responseModel: ExternalCheckoutRes.self, timeout: 60)
        return (link: response.resource.data.link, checkoutToken: response.resource.data.token)
    }

    public func createPaymentSourceToken(checkoutToken: String, gatewayId: String, widgetAccessToken: String) async throws -> String {
        let request = CreatePaymentSourceTokenFromCheckoutReq(checkoutToken: checkoutToken, gatewayId: gatewayId)
        let endpoint = PaymentSourcesEndpoints.zipToken(request: request, widgetAccessToken: widgetAccessToken)
        let response = try await sendRequest(endpoint: endpoint, responseModel: PaymentSourceTokenRes.self, timeout: 60)
        return response.resource.data
    }
}
