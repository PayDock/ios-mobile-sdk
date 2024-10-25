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

    case sdkException(description: String)
    case userCancelled
    case unknownError

    public var customMessage: String {
        switch self {
        case .sdkException(let description): return description
        case .userCancelled: return "User canceled the operation."
        case .unknownError: return "Unknown error"
        }
    }
}
