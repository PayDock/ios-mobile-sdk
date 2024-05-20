//
//  ApplePayError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 05.10.2023..
//

import Foundation

public enum ApplePayError: Error {

    case invalidApplePayRequest

    case initFailed
    case paymentFailed(error: ErrorRes)
    case unknownError

    public var customMessage: String {
        switch self {
        case .invalidApplePayRequest: return "Missing or invalid ApplePayRequest object"
        case .initFailed: return "Initialisation of ApplePay has failed"
        case .paymentFailed: return "Payment failed"
        case .unknownError: return "Unknown error"
        }
    }
}
