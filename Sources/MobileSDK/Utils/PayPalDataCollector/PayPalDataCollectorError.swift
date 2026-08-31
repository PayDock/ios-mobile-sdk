//
//  PayPalDataCollectorError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 06.11.2024..
//

import Foundation
import NetworkingLib

public enum PayPalDataCollectorError: Error, WidgetError {

    case initialisationClientId(error: ErrorRes)
    case parsingError
    case unknownError(RequestError?)

    public var customMessage: String {
        switch self {
        case .initialisationClientId: return "Error getting PayPal client ID."
        case .parsingError: return "Error parsing received Device Data model."
        case .unknownError: return "Unknown error"
        }
    }

    public var code: String {
        switch self {
        case .initialisationClientId: return "PAYPAL_DATA_COLLECTOR_CLIENT_ID_ERROR"
        case .parsingError: return "PAYPAL_DATA_COLLECTOR_PARSING_ERROR"
        case let .unknownError(requestError): return "PAYPAL_DATA_COLLECTOR_" + (requestError?.diagnosticCode ?? "UNKNOWN")
        }
    }

    public var debugDescription: String {
        switch self {
        case .initialisationClientId(let errorRes):
            return "\(code): \(customMessage) [\(errorRes.technicalDetail)]"
        case let .unknownError(requestError):
            let detail = requestError?.technicalDescription ?? "no underlying error"
            return "\(code): \(customMessage) [\(detail)]"
        case .parsingError:
            return "\(code): \(customMessage)"
        }
    }
}
