//
//  FlyPayError.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 17.01.2024..
//

import Foundation

public enum FlyPayError: Error {

    case requestFailed
    case webViewFailed

    public var customMessage: String {
        switch self {
        case .requestFailed:
            return "FlyPay payment request has failed! There was an issue with your request."
        case .webViewFailed:
            return "FlyPay WebView widget has failed"
        }
    }
}

