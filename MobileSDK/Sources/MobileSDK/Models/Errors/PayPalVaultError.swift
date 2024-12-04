//
//  PayPalVaultError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 16.10.2024..
//

import Foundation
import NetworkingLib

public enum PayPalVaultError: Error {

<<<<<<< HEAD
=======
    case createSessionAuthToken(error: ErrorRes)
>>>>>>> main
    case createSetupToken(error: ErrorRes)
    case getPayPalClientId(error: ErrorRes)
    case createPaymentToken(error: ErrorRes)
    case sdkException(description: String)
    case userCancelled
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
<<<<<<< HEAD
=======
        case .createSessionAuthToken: return "Error creating session auth token."
>>>>>>> main
        case .createSetupToken: return "Error creating setup token."
        case .getPayPalClientId: return "Error getting PayPal client ID."
        case .createPaymentToken: return "Error creating payment token."
        case .sdkException(let description): return description
        case .userCancelled: return "User canceled the operation."
        case .unknownError: return "Unknown error"
        }
    }
}
