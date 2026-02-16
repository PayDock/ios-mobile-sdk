//
//  ApplePayError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum ApplePayError: Error {

    case invalidApplePayRequest
    case errorInitializingPayment
    case errorCompletingPayment(error: ErrorRes)
    case userCanceledPayment
    case unableToPresentPaymentSheet
    case creatingPaymentRequest(reason: String)
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .invalidApplePayRequest: return "Missing or invalid ApplePayRequest object"
        case .errorInitializingPayment: return "Initialisation of ApplePay has failed"
        case .errorCompletingPayment(let errorRes):
                return errorRes.apiFailureMessage(fallback: "Payment failed")
        case .userCanceledPayment: return "User has canceled the payment"
        case .unableToPresentPaymentSheet: return "Unable to present ApplePay sheet - check the provided Merchant ID"
        case .creatingPaymentRequest(let reason): return reason
        case .unknownError(let requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }
}
