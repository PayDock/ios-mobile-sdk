//
//  PayPalError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 02.11.2023..
//

import Foundation
import NetworkingLib

public enum PayPalError: Error {

    case errorFetchingPayPalUrl(error: ErrorRes)
    case errorCapturingCharge(error: ErrorRes)
    case webViewFailed(error: NSError)
    case transactionCanceled
    case unknownError

    public var customMessage: String {
        switch self {
        case .errorFetchingPayPalUrl: return "Unable to fetch PayPal widget URL"
        case .errorCapturingCharge: return "Unable to complete the charge"
        case .webViewFailed: return "PayPal WebView widget has failed"
        case .transactionCanceled: return "PayPal transaction was canceled."
        case .unknownError: return "Unknown error"
        }
    }
}
