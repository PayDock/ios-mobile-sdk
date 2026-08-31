//
//  CardDetailsError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import NetworkingLib

public enum CardDetailsError: Error, WidgetError {

    case errorTokenisingCard(error: ErrorRes)
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .errorTokenisingCard(let errorRes):
                return errorRes.apiFailureMessage(fallback: "Error tokenising card")
        case .unknownError(let requestError): return requestError?.uiMessage ?? "Unknown error"
        }
    }

    public var code: String {
        switch self {
        case .errorTokenisingCard: return "CARD_TOKENISE_ERROR"
        case let .unknownError(requestError): return "CARD_" + (requestError?.diagnosticCode ?? "UNKNOWN")
        }
    }

    public var debugDescription: String {
        switch self {
        case .errorTokenisingCard(let errorRes):
            return "\(code): \(customMessage) [\(errorRes.technicalDetail)]"
        case let .unknownError(requestError):
            let detail = requestError?.technicalDescription ?? "no underlying error"
            return "\(code): \(customMessage) [\(detail)]"
        }
    }
}
