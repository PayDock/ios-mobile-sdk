//
//  ZipError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import NetworkingLib

public enum ZipError: Error {

    case errorFetchingZipUrl(error: ErrorRes)
    case errorCapturingCharge(error: ErrorRes)
    case webViewFailed(error: NSError)
    case transactionCanceled(checkoutId: String?)
    case transactionDeclined(checkoutId: String?)
    case transactionReferred(checkoutId: String?)
    case unexpectedStatus(status: String?, checkoutId: String?)
    case initialisingWalletToken(reason: String)
    case unknownError

    public var customMessage: String {
        switch self {
        case .errorFetchingZipUrl: return "Unable to fetch Zip widget URL"
        case .errorCapturingCharge: return "Unable to complete the charge"
        case .webViewFailed: return "Zip WebView widget has failed"
        case .transactionCanceled: return "Zip transaction was canceled"
        case .transactionDeclined: return "Zip transaction was declined"
        case .transactionReferred: return "Zip transaction requires review (referred)"
        case .unexpectedStatus(let status, _): return "Unexpected Zip status: \(status ?? "unknown")"
        case .initialisingWalletToken(let reason): return reason
        case .unknownError: return "Unknown error"
        }
    }

    /// Get the checkout ID associated with this error, if available
    public var checkoutId: String? {
        switch self {
        case .transactionCanceled(let id),
             .transactionDeclined(let id),
             .transactionReferred(let id),
             .unexpectedStatus(_, let id):
            return id
        default:
            return nil
        }
    }
}
