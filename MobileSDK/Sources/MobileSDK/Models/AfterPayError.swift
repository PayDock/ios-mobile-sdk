//
//  AfterPayError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.02.2024..
//

import Foundation

public enum AfterPayError: Error {

    case requestFailed
    case webViewFailed
    case transactionCanceled

    public var customMessage: String {
        switch self {
        case .requestFailed: return "Afterpay payment request has failed! There was an issue with your request."
        case .webViewFailed: return "Afterpay WebView widget has failed."
        case .transactionCanceled: return "Afterpay transaction was canceled."
        }
    }
}

