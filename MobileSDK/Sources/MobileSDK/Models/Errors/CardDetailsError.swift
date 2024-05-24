//
//  CardDetailsError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 06.12.2023..
//

import Foundation

public enum CardDetailsError: Error {

    case errorTokenisingCard(error: ErrorRes)
    case unknownError

    public var customMessage: String {
        switch self {
        case let .errorTokenisingCard(error): return error.error?.message ?? "Error tokenising gift card"
        case .unknownError: return "Unknown error occured"
        }
    }
}
