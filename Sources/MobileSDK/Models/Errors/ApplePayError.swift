//
//  ApplePayError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum ApplePayError: Error, LocalizedError {

    case notSupported
    case noSupportedCardsInWallet
    case errorCreatingToken(error: ErrorRes)
    case userCanceledPayment
    case unableToPresentPaymentSheet
    case payloadEncodingFailed
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .notSupported: return "Apple Pay is not supported"
        case .noSupportedCardsInWallet: return "No supported cards in Wallet"
        case .errorCreatingToken(let error): return error.error?.message ?? "Failed to create Apple Pay token"
        case .userCanceledPayment: return "User has canceled the payment"
        case .unableToPresentPaymentSheet: return "Unable to present ApplePay sheet - check the provided Merchant ID"
        case .payloadEncodingFailed: return "Failed to encode Apple Pay payment data"
        case let .unknownError(requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }

    public var errorDescription: String? {
        return customMessage
    }
}
