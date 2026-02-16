//
//  ClickToPayError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

public enum ClickToPayError: Error {
    case webViewFailed(error: NSError)
    case unknownError

    public var customMessage: String {
        switch self {
        case .webViewFailed(let nsError):
            return nsError.webViewFailureMessage(fallback: "ClickToPay WebView widget has failed")
        case .unknownError: return "Unknown error"
        }
    }
}
