//
//  CardDetailsError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 06.12.2023..
//

import Foundation
import NetworkingLib

public enum CardDetailsError: Error {

    case errorTokenisingCard(error: ErrorRes)
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case let .errorTokenisingCard(error): return error.error?.message ?? "Error tokenising gift card"
        case let .unknownError(requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }
}
