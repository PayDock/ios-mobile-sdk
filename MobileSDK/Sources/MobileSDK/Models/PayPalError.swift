//
//  PayPalError.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 02.11.2023..
//

import Foundation

public enum PayPalError: Error {

    case requestFailed
    case webViewFailed

    public var customMessage: String {
        switch self {
        case .requestFailed:
            return "PayPal payment request has failed! There was an issue with your request."
        case .webViewFailed:
            return "PayPal WebView widget has failed"
        }
    }
}
