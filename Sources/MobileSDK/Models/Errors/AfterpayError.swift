//
//  AfterpayError.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.02.2024..
//

import Foundation
import NetworkingLib

public enum AfterpayError: Error {

    case errorFetchingAfterpayUrl(error: ErrorRes)
    case errorCapturingCharge(error: ErrorRes)
    case errorCancelingTransaction(error: ErrorRes)
    case transactionCanceled
    case unknownError

    public var customMessage: String {
        switch self {
        case .errorFetchingAfterpayUrl: return "Unable to fetch Afterpay widget URL"
        case .errorCapturingCharge: return "Unable to complete the charge"
        case .errorCancelingTransaction: return "Unable to cancel transaction"
        case .transactionCanceled: return "Afterpay transaction was canceled."
        case .unknownError: return "Unknown error"
        }
    }
}

