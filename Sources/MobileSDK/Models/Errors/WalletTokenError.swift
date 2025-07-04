//
//  WalletTokenError.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 16.06.2025..
//  Copyright © 2025 Paydock Ltd.
//

public enum WalletTokenError: Error, Equatable {
    
    case initialisingWalletToken(reason: String?)
    
    public var customMessage: String {
        switch self {
        case .initialisingWalletToken(let reason): return reason ?? "An unexpected error occurred while retrieving token."
        }
    }
}
