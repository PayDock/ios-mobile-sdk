//
//  ApplePayError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum ApplePayError: Error, LocalizedError, WidgetError {

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

    public var code: String {
        switch self {
        case .notSupported: return "APPLE_PAY_NOT_SUPPORTED"
        case .noSupportedCardsInWallet: return "APPLE_PAY_NO_SUPPORTED_CARDS"
        case .errorCreatingToken: return "APPLE_PAY_TOKEN_ERROR"
        case .userCanceledPayment: return "APPLE_PAY_USER_CANCELED"
        case .unableToPresentPaymentSheet: return "APPLE_PAY_PRESENT_FAILED"
        case .payloadEncodingFailed: return "APPLE_PAY_PAYLOAD_ENCODING_FAILED"
        case let .unknownError(requestError): return "APPLE_PAY_" + (requestError?.diagnosticCode ?? "UNKNOWN")
        }
    }

    public var debugDescription: String {
        switch self {
        case .errorCreatingToken(let error):
            return "\(code): \(customMessage) [\(error.technicalDetail)]"
        case let .unknownError(requestError):
            let detail = requestError?.technicalDescription ?? "no underlying error"
            return "\(code): \(customMessage) [\(detail)]"
        default:
            return "\(code): \(customMessage)"
        }
    }

    public var errorDescription: String? {
        return customMessage
    }
}
