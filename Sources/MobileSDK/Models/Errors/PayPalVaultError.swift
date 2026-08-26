//
//  PayPalVaultError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum PayPalVaultError: Error, WidgetError {

    case createSetupToken(error: ErrorRes)
    case getPayPalClientId(error: ErrorRes)
    case createPaymentToken(error: ErrorRes)
    case sdkException(description: String)
    case userCancelled
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .createSetupToken(let errorRes):
            return errorRes.apiFailureMessage(fallback: "Error creating setup token")
        case .getPayPalClientId(let errorRes):
            return errorRes.apiFailureMessage(fallback: "Error getting PayPal client ID")
        case .createPaymentToken(let errorRes):
            return errorRes.apiFailureMessage(fallback: "Error creating payment token")
        case .sdkException(let description): return description
        case .userCancelled: return "User canceled the operation."
        case .unknownError(let requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }

    public var code: String {
        switch self {
        case .createSetupToken: return "PAYPAL_VAULT_SETUP_TOKEN_ERROR"
        case .getPayPalClientId: return "PAYPAL_VAULT_CLIENT_ID_ERROR"
        case .createPaymentToken: return "PAYPAL_VAULT_PAYMENT_TOKEN_ERROR"
        case .sdkException: return "PAYPAL_VAULT_SDK_EXCEPTION"
        case .userCancelled: return "PAYPAL_VAULT_USER_CANCELED"
        case let .unknownError(requestError): return "PAYPAL_VAULT_" + (requestError?.diagnosticCode ?? "UNKNOWN")
        }
    }

    public var debugDescription: String {
        switch self {
        case .createSetupToken(let errorRes),
             .getPayPalClientId(let errorRes),
             .createPaymentToken(let errorRes):
            return "\(code): \(customMessage) [\(errorRes.technicalDetail)]"
        case let .unknownError(requestError):
            let detail = requestError?.technicalDescription ?? "no underlying error"
            return "\(code): \(customMessage) [\(detail)]"
        default:
            return "\(code): \(customMessage)"
        }
    }
}
