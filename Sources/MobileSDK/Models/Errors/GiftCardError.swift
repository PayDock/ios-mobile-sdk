//
//  GiftCardError.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 16.05.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import NetworkingLib

public enum GiftCardError: Error {

    case errorTokenisingCard(error: ErrorRes)
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case let .errorTokenisingCard(error): return error.error?.message ?? "Error tokenising gift card"
        case .unknownError(let requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }
}
