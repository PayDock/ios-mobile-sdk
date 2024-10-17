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

    // TODO: - Add cases once we know possible error states for the vault
    case unknownError

    public var customMessage: String {
        switch self {
        case .unknownError: return "Unknown error"
        }
    }
}
