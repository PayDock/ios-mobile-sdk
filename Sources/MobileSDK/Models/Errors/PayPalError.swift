//
//  PayPalError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 02.11.2023..
//

import Foundation
import NetworkingLib

public enum PayPalError: Error, WidgetError {

    case getPayPalClientId(error: ErrorRes)
    case errorFetchingOrderId(error: ErrorRes)
    case errorCapturingCharge(error: ErrorRes)
    case userCancelled
    case initialisingWalletToken(reason: String)
    case sdkException(description: String)
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .getPayPalClientId(let errorRes):
            return errorRes.apiFailureMessage(fallback: "Error getting PayPal client ID")
        case .errorFetchingOrderId(let errorRes):
            return errorRes.apiFailureMessage(fallback: "Unable to fetch PayPal order ID")
        case .errorCapturingCharge(let errorRes):
            return errorRes.apiFailureMessage(fallback: "Unable to complete the charge")
        case .userCancelled: return "PayPal transaction was canceled."
        case .initialisingWalletToken(let reason): return reason
        case .sdkException(let description): return description
        case .unknownError(let requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }

    public var code: String {
        switch self {
        case .getPayPalClientId: return "PAYPAL_CLIENT_ID_ERROR"
        case .errorFetchingOrderId: return "PAYPAL_FETCH_ORDER_ERROR"
        case .errorCapturingCharge: return "PAYPAL_CAPTURE_CHARGE_ERROR"
        case .userCancelled: return "PAYPAL_USER_CANCELED"
        case .initialisingWalletToken: return "PAYPAL_WALLET_TOKEN_ERROR"
        case .sdkException: return "PAYPAL_SDK_EXCEPTION"
        case let .unknownError(requestError): return "PAYPAL_" + (requestError?.diagnosticCode ?? "UNKNOWN")
        }
    }

    public var debugDescription: String {
        switch self {
        case .getPayPalClientId(let errorRes),
             .errorFetchingOrderId(let errorRes),
             .errorCapturingCharge(let errorRes):
            return "\(code): \(customMessage) [\(errorRes.technicalDetail)]"
        case let .unknownError(requestError):
            let detail = requestError?.technicalDescription ?? "no underlying error"
            return "\(code): \(customMessage) [\(detail)]"
        default:
            return "\(code): \(customMessage)"
        }
    }
}
