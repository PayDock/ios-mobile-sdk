//
//  ColesPayError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum ColesPayError: Error {

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
}
