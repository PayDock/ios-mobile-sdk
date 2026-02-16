//
//  AfterpayError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum AfterpayError: Error {

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
}
