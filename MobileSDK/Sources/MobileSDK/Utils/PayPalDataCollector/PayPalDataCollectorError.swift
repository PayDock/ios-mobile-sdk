//
//  PayPalDataCollectorError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 06.11.2024..
//

import Foundation
import NetworkingLib

public enum PayPalDataCollectorError: Error {

    case initialisationClientId(error: ErrorRes)
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .initialisationClientId: return "Error getting PayPal client ID."
        case .unknownError: return "Unknown error"
        }
    }
}
