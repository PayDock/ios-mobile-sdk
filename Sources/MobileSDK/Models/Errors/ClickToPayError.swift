//
//  ClickToPayError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

public enum ClickToPayError: Error, WidgetError {
    case webViewFailed(error: NSError)
    case unknownError

    public var customMessage: String {
        switch self {
        case .webViewFailed(let nsError):
            return nsError.webViewFailureMessage(fallback: "ClickToPay WebView widget has failed")
        case .unknownError: return "Unknown error"
        }
    }

    public var code: String {
        switch self {
        case .webViewFailed: return "CLICK_TO_PAY_WEBVIEW_FAILED"
        case .unknownError: return "CLICK_TO_PAY_UNKNOWN"
        }
    }

    public var debugDescription: String {
        switch self {
        case .webViewFailed(let nsError):
            return "\(code): \(customMessage) [\(nsError.domain) code \(nsError.code)]"
        case .unknownError:
            return "\(code): \(customMessage)"
        }
    }
}
