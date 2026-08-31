//
//  AfterpayError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum AfterpayError: Error, WidgetError {

    case errorFetchingAfterpayUrl(error: ErrorRes)
    case errorCapturingCharge(error: ErrorRes)
    case errorCancelingTransaction(error: ErrorRes)
    case transactionCanceled
    case initialisingWalletToken(reason: String)
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .errorFetchingAfterpayUrl(let errorRes):
                return errorRes.apiFailureMessage(fallback: "Unable to fetch Afterpay widget URL")
        case .errorCapturingCharge(let errorRes):
                return errorRes.apiFailureMessage(fallback: "Unable to complete the charge")
        case .errorCancelingTransaction(let errorRes):
                return errorRes.apiFailureMessage(fallback: "Unable to cancel transaction")
        case .transactionCanceled: return "Afterpay transaction was canceled."
        case .initialisingWalletToken(let reason): return reason
        case .unknownError(let requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }

    public var code: String {
        switch self {
        case .errorFetchingAfterpayUrl: return "AFTERPAY_FETCH_URL_ERROR"
        case .errorCapturingCharge: return "AFTERPAY_CAPTURE_CHARGE_ERROR"
        case .errorCancelingTransaction: return "AFTERPAY_CANCEL_TRANSACTION_ERROR"
        case .transactionCanceled: return "AFTERPAY_TRANSACTION_CANCELED"
        case .initialisingWalletToken: return "AFTERPAY_WALLET_TOKEN_ERROR"
        case let .unknownError(requestError): return "AFTERPAY_" + (requestError?.diagnosticCode ?? "UNKNOWN")
        }
    }

    public var debugDescription: String {
        switch self {
        case .errorFetchingAfterpayUrl(let errorRes),
             .errorCapturingCharge(let errorRes),
             .errorCancelingTransaction(let errorRes):
            return "\(code): \(customMessage) [\(errorRes.technicalDetail)]"
        case let .unknownError(requestError):
            let detail = requestError?.technicalDescription ?? "no underlying error"
            return "\(code): \(customMessage) [\(detail)]"
        default:
            return "\(code): \(customMessage)"
        }
    }
}
