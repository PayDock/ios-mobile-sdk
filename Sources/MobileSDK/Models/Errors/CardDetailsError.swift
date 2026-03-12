//
//  CardDetailsError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum CardDetailsError: Error {

    case errorTokenisingCard(error: ErrorRes)
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .errorTokenisingCard(let errorRes):
                return errorRes.apiFailureMessage(fallback: "Error tokenising card")
        case .unknownError(let requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }
}
