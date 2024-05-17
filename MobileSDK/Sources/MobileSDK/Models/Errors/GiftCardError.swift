//
//  GiftCardError.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 16.05.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public enum GiftCardError: Error {

    case errorTokenisingCard(error: ErrorRes)

    public var customMessage: String {
        switch self {
        case let .errorTokenisingCard(error):
            return "Error tokenising card details!"
        }
    }
}
