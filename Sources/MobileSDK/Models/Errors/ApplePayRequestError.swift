//
//  ApplePayRequestError.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.06.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public enum ApplePayRequestError: Error {

    case initialisingWalletToken(reason: String?)

    public var customMessage: String {
        switch self {
        case .initialisingWalletToken(let reason): return reason ?? "An unexpected error occurred while retrieving token."
        }
    }
}
