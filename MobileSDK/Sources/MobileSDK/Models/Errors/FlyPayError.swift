//
//  FlyPayError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 17.01.2024..
//

import Foundation
import NetworkingLib

public enum FlyPayError: Error {

    case errorFetchingFlyPayOrder(error: ErrorRes)
    case flyPayUrlError
    case webViewFailed(error: NSError)
    case unknownError

    public var customMessage: String {
        switch self {
        case .errorFetchingFlyPayOrder: return "Unable to fetch FlyPay widget order ID"
        case .flyPayUrlError: return "Failure trying to generate FlyPay URL"
        case .webViewFailed: return "FlyPay WebView widget has failed"
        case .unknownError: return "Unknown error"
        }
    }
}

