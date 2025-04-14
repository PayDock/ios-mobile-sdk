//
//  ApplePayError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 05.10.2023..
//

import Foundation
import NetworkingLib

public enum ApplePayError: Error {

    case invalidApplePayRequest
    case errorInitializingPayment
    case errorCompletingPayment(error: ErrorRes)
    case userCanceledPayment
    case unableToPresentPaymentSheet
    case unknownError

    public var customMessage: String {
        switch self {
        case .invalidApplePayRequest: return "Missing or invalid ApplePayRequest object"
        case .errorInitializingPayment: return "Initialisation of ApplePay has failed"
        case .errorCompletingPayment: return "Payment failed"
        case .userCanceledPayment: return "User has canceled the payment"
        case .unableToPresentPaymentSheet: return "Unable to present ApplePay sheet - check the provided Merchant ID"
        case .unknownError: return "Unknown error"
        }
    }
}
