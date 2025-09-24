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

    case getPayPalClientId(error: ErrorRes)
    case errorFetchingOrderId(error: ErrorRes)
    case errorCapturingCharge(error: ErrorRes)
    case userCancelled
    case initialisingWalletToken(reason: String)
    case sdkException(description: String)
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .getPayPalClientId: return "Error getting PayPal client ID."
        case .errorFetchingOrderId: return "Unable to fetch PayPal order ID"
        case .errorCapturingCharge: return "Unable to complete the charge"
        case .userCancelled: return "PayPal transaction was canceled."
        case .initialisingWalletToken(let reason): return reason
        case .sdkException(let description): return description
        case .unknownError(let requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }
}
