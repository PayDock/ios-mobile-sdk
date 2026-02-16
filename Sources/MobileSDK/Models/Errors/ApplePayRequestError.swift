//
//  ApplePayRequestError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

public enum ApplePayRequestError: Error {

    case initialisingWalletToken(reason: String?)

    public var customMessage: String {
        switch self {
        case .initialisingWalletToken(let reason): return reason ?? "An unexpected error occurred while retrieving token."
        }
    }
}
