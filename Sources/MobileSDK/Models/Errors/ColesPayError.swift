//
//  ColesPayError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum ColesPayError: Error, WidgetError {

    case errorFetchingColesPayOrder(error: ErrorRes)
    case colesPayUrlError
    case webViewFailed(error: NSError)
    case transactionCanceled
    case initialisingWalletToken(reason: String)
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .errorFetchingColesPayOrder(let errorRes):
                return errorRes.apiFailureMessage(fallback: "Unable to fetch Coles Pay widget order ID")
        case .colesPayUrlError: return "Failure trying to generate Coles Pay URL"
        case .webViewFailed(let nsError):
            return nsError.webViewFailureMessage(fallback: "Coles Pay WebView widget has failed")
        case .transactionCanceled: return "Coles Pay transaction was canceled."
        case .initialisingWalletToken(let reason): return reason
        case .unknownError(let requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }

    public var code: String {
        switch self {
        case .errorFetchingColesPayOrder: return "COLES_PAY_FETCH_ORDER_ERROR"
        case .colesPayUrlError: return "COLES_PAY_URL_ERROR"
        case .webViewFailed: return "COLES_PAY_WEBVIEW_FAILED"
        case .transactionCanceled: return "COLES_PAY_TRANSACTION_CANCELED"
        case .initialisingWalletToken: return "COLES_PAY_WALLET_TOKEN_ERROR"
        case let .unknownError(requestError): return "COLES_PAY_" + (requestError?.diagnosticCode ?? "UNKNOWN")
        }
    }

    public var debugDescription: String {
        switch self {
        case .errorFetchingColesPayOrder(let errorRes):
            return "\(code): \(customMessage) [\(errorRes.technicalDetail)]"
        case .webViewFailed(let nsError):
            return "\(code): \(customMessage) [\(nsError.domain) code \(nsError.code)]"
        case let .unknownError(requestError):
            let detail = requestError?.technicalDescription ?? "no underlying error"
            return "\(code): \(customMessage) [\(detail)]"
        default:
            return "\(code): \(customMessage)"
        }
    }
}
