//
//  Standalone3DSError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

public enum Standalone3DSError: Error, Equatable, WidgetError {
    case webViewFailed(error: NSError)
    case invalidToken
    case mappingFailed

    public var customMessage: String {
        switch self {
        case .webViewFailed(let nsError):
            return nsError.webViewFailureMessage(fallback: "3DS WebView widget has failed")
        case .invalidToken: return "Provided 3DS token is not valid"
        case .mappingFailed: return "3DS response mapping failed"
        }
    }

    public var code: String {
        switch self {
        case .webViewFailed: return "STANDALONE_3DS_WEBVIEW_FAILED"
        case .invalidToken: return "STANDALONE_3DS_INVALID_TOKEN"
        case .mappingFailed: return "STANDALONE_3DS_RESPONSE_MAPPING_FAILED"
        }
    }

    public var debugDescription: String {
        switch self {
        case .webViewFailed(let nsError):
            return "\(code): \(customMessage) [\(nsError.domain) code \(nsError.code)]"
        default:
            return "\(code): \(customMessage)"
        }
    }
}
