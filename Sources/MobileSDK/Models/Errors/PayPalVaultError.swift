//
//  PayPalVaultError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum PayPalVaultError: Error {

    case createSetupToken(error: ErrorRes)
    case getPayPalClientId(error: ErrorRes)
    case createPaymentToken(error: ErrorRes)
    case sdkException(description: String)
    case userCancelled
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .createSetupToken(let errorRes):
            return errorRes.apiFailureMessage(fallback: "Error creating setup token")
        case .getPayPalClientId(let errorRes):
            return errorRes.apiFailureMessage(fallback: "Error getting PayPal client ID")
        case .createPaymentToken(let errorRes):
            return errorRes.apiFailureMessage(fallback: "Error creating payment token")
        case .sdkException(let description): return description
        case .userCancelled: return "User canceled the operation."
        case .unknownError(let requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }
}
