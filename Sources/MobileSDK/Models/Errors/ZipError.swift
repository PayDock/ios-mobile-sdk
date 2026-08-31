//
//  ZipError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum ZipError: Error, WidgetError {

    case errorFetchingZipUrl(error: ErrorRes)
    case errorCapturingCharge(error: ErrorRes)
    case invalidCheckoutUrl
    case webViewFailed(error: NSError)
    case transactionCanceled(checkoutId: String?)
    case transactionDeclined(checkoutId: String?)
    case transactionReferred(checkoutId: String?)
    case unexpectedStatus(status: String?, checkoutId: String?)
    case initialisingWalletToken(reason: String)
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .errorFetchingZipUrl(let errorRes):
            return errorRes.apiFailureMessage(fallback: "Unable to fetch Zip widget URL")
        case .errorCapturingCharge(let errorRes):
            return errorRes.apiFailureMessage(fallback: "Unable to complete the charge")
        case .invalidCheckoutUrl:
            return "Unsupported URL - unable to proceed."
        case .webViewFailed(let nsError):
                return nsError.webViewFailureMessage(fallback: "Zip WebView widget has failed")
        case .transactionCanceled: return "Zip transaction was canceled"
        case .transactionDeclined: return "Zip transaction was declined"
        case .transactionReferred: return "Zip transaction requires review (referred)"
        case .unexpectedStatus(let status, _): return "Unexpected Zip status: \(status ?? "unknown")"
        case .initialisingWalletToken(let reason): return reason
        case .unknownError(let requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }

    public var code: String {
        switch self {
        case .errorFetchingZipUrl: return "ZIP_FETCH_URL_ERROR"
        case .errorCapturingCharge: return "ZIP_CAPTURE_CHARGE_ERROR"
        case .invalidCheckoutUrl: return "ZIP_INVALID_CHECKOUT_URL"
        case .webViewFailed: return "ZIP_WEBVIEW_FAILED"
        case .transactionCanceled: return "ZIP_TRANSACTION_CANCELED"
        case .transactionDeclined: return "ZIP_TRANSACTION_DECLINED"
        case .transactionReferred: return "ZIP_TRANSACTION_REFERRED"
        case .unexpectedStatus: return "ZIP_UNEXPECTED_STATUS"
        case .initialisingWalletToken: return "ZIP_WALLET_TOKEN_ERROR"
        case let .unknownError(requestError): return "ZIP_" + (requestError?.diagnosticCode ?? "UNKNOWN")
        }
    }

    public var debugDescription: String {
        switch self {
        case .errorFetchingZipUrl(let errorRes),
             .errorCapturingCharge(let errorRes):
            return "\(code): \(customMessage) [\(errorRes.technicalDetail)]"
        case .webViewFailed(let nsError):
            return "\(code): \(customMessage) [\(nsError.domain) code \(nsError.code)]"
        case let .unknownError(requestError):
            let detail = requestError?.technicalDescription ?? "no underlying error"
            return "\(code): \(customMessage) [\(detail)]"
        default:
            let suffix = checkoutId.map { " [checkoutId: \($0)]" } ?? ""
            return "\(code): \(customMessage)\(suffix)"
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
