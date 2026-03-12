//
//  MPGS3dsError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

public enum MPGS3dsError: Error, Equatable {
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
}
