//
//  ApplePayError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum ApplePayError: Error {

    case invalidApplePayRequest
    case errorCreatingToken(error: ErrorRes)
    case userCanceledPayment
    case unableToPresentPaymentSheet
    case payloadEncodingFailed
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .invalidApplePayRequest: return "Missing or invalid ApplePayRequest object"
        case .errorCreatingToken(let error): return error.error?.message ?? "Failed to create Apple Pay token"
        case .userCanceledPayment: return "User has canceled the payment"
        case .unableToPresentPaymentSheet: return "Unable to present ApplePay sheet - check the provided Merchant ID"
        case .payloadEncodingFailed: return "Failed to encode Apple Pay payment data"
        case let .unknownError(requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }
}
