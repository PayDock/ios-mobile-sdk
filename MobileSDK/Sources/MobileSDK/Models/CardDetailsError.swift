//
//  CardDetailsError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 06.12.2023..
//

import Foundation

public enum CardDetailsError: Error {

    case errorTokenisingCard

    public var customMessage: String {
        switch self {
        case .errorTokenisingCard:
            return "Error tokenising card details!"
        }
    }
}
