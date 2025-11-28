//
//  PaymentSourcesEndpoints.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.

import Foundation
import NetworkingLib

/// All `/v1/payment_sources/*` endpoints
enum PaymentSourcesEndpoints {

    // MARK: - Card & Gift Card Tokens

    case cardToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq, accessToken: String)
    case giftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq, accessToken: String)

    // MARK: - PayPal Vault Tokens

    case setupToken(request: PayPalVaultSetupTokenReq, accessToken: String)
    case paymentToken(setupToken: String, request: PayPalVaultPaymentTokenReq, accessToken: String)

    // MARK: - External Checkout (Zip)

    case externalCheckout(accessToken: String, request: ExternalCheckoutReq)
    case zipToken(request: PaymentSourceTokenReq, accessToken: String)
}

extension PaymentSourcesEndpoints: Endpoint {

    var path: String {
        switch self {
        case .cardToken, .giftCardToken, .zipToken:
            return "/v1/payment_sources/tokens"
        case .setupToken:
            return "/v1/payment_sources/setup-tokens"
        case .paymentToken(let setupToken, _, _):
            return "/v1/payment_sources/setup-tokens/\(setupToken)/tokens"
        case .externalCheckout:
            return "/v1/payment_sources/external_checkout"
        }
    }

    var method: RequestMethod {
        switch self {
        case .cardToken, .giftCardToken, .setupToken, .paymentToken, .externalCheckout, .zipToken:
            return .post
        }
    }

    var header: [String: String]? {
        switch self {
        case let .cardToken(_, accessToken),
             let .giftCardToken(_, accessToken),
             let .setupToken(_, accessToken),
             let .paymentToken(_, _, accessToken),
             let .externalCheckout(accessToken, _),
             let .zipToken(_, accessToken):
            return [
                "x-access-token": "\(accessToken)",
                "Content-Type": "application/json"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .cardToken(let request, _):
            return try? encoder.encode(request)
        case .giftCardToken(let request, _):
            return try? encoder.encode(request)
        case .setupToken(let request, _):
            return try? encoder.encode(request)
        case .paymentToken(_, let request, _):
            return try? encoder.encode(request)
        case .externalCheckout(_, let request):
            return try? encoder.encode(request)
        case .zipToken(let request, _):
            return try? encoder.encode(request)
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        default: return []
        }
    }

    var mockFile: String? {
        switch self {
        case .cardToken, .giftCardToken, .externalCheckout, .zipToken:
            return nil
        case .setupToken:
            return "paypal_vault_setup_token_success_response"
        case .paymentToken:
            return "paypal_vault_payment_token_success_response"
        }
    }

    var bundle: Bundle? {
        switch self {
        case .cardToken, .giftCardToken, .setupToken, .paymentToken, .externalCheckout, .zipToken:
            return Bundle.module
        }
    }
}
