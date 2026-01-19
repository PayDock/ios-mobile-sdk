//
//  PaymentSourcesEndpoints.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// All `/v1/payment_sources/*` endpoints
public enum PaymentSourcesEndpoints {

    // MARK: - Card & Gift Card Tokens

    case cardToken(tokeniseCardDetailsReq: CreatePaymentSourceTokenReq, widgetAccessToken: String)
    case giftCardToken(tokeniseGiftCardReq: CreateGiftCardTokenReq, widgetAccessToken: String)
    case applePayToken(tokeniseApplePayReq: CreateApplePayTokenReq, widgetAccessToken: String)

    // MARK: - PayPal Vault Tokens

    case setupToken(request: CreatePayPalVaultSetupTokenReq, widgetAccessToken: String)
    case paymentToken(setupToken: String, request: CreatePayPalVaultPaymentTokenReq, widgetAccessToken: String)

    // MARK: - External Checkout (Zip)

    case externalCheckout(request: CreateExternalCheckoutReq, widgetAccessToken: String)
    case zipToken(request: CreatePaymentSourceTokenFromCheckoutReq, widgetAccessToken: String)
}

extension PaymentSourcesEndpoints: Endpoint {

    public var path: String {
        switch self {
        case .cardToken, .giftCardToken, .applePayToken, .zipToken:
            return "/v1/payment_sources/tokens"
        case .setupToken:
            return "/v1/payment_sources/setup-tokens"
        case .paymentToken(let setupToken, _, _):
            return "/v1/payment_sources/setup-tokens/\(setupToken)/tokens"
        case .externalCheckout:
            return "/v1/payment_sources/external_checkout"
        }
    }

    public var method: RequestMethod {
        switch self {
        case .cardToken, .giftCardToken, .applePayToken, .setupToken, .paymentToken, .externalCheckout, .zipToken:
            return .post
        }
    }

    public var header: [String: String]? {
        let widgetAccessToken: String
        switch self {
        case let .cardToken(_, token),
             let .giftCardToken(_, token),
             let .applePayToken(_, token),
             let .setupToken(_, token),
             let .paymentToken(_, _, token),
             let .externalCheckout(_, token),
             let .zipToken(_, token):
            widgetAccessToken = token
        }
        return [
            "x-access-token": widgetAccessToken,
            "Content-Type": "application/json;charset=utf-8"
        ]
    }

    public var body: Data? {
        switch self {
        case .cardToken(let request, _):
            return try? encoder.encode(request)
        case .giftCardToken(let request, _):
            return try? encoder.encode(request)
        case .applePayToken(let request, _):
            return try? encoder.encode(request)
        case .setupToken(let request, _):
            return try? encoder.encode(request)
        case .paymentToken(_, let request, _):
            return try? encoder.encode(request)
        case .externalCheckout(let request, _):
            return try? encoder.encode(request)
        case .zipToken(let request, _):
            return try? encoder.encode(request)
        }
    }

    public var parameters: [URLQueryItem] {
        switch self {
        default: return []
        }
    }

    public var mockFile: String? {
        switch self {
        case .cardToken, .giftCardToken, .applePayToken, .externalCheckout, .zipToken:
            return nil
        case .setupToken:
            return "paypal_vault_setup_token_success_response"
        case .paymentToken:
            return "paypal_vault_payment_token_success_response"
        }
    }

    public var bundle: Bundle? {
        switch self {
        case .cardToken, .giftCardToken, .applePayToken, .setupToken, .paymentToken, .externalCheckout, .zipToken:
//            return Bundle.module
                return nil
        }
    }
}
