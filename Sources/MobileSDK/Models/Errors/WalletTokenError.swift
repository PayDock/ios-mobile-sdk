//
//  WalletTokenError.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

public enum WalletTokenError: Error, Equatable, WidgetError {

    case initialisingWalletToken(reason: String?)

    public var customMessage: String {
        switch self {
        case .initialisingWalletToken(let reason): return reason ?? "An unexpected error occurred while retrieving token."
        }
    }

    public var code: String {
        switch self {
        case .initialisingWalletToken: return "WALLET_TOKEN_INIT_ERROR"
        }
    }

    public var debugDescription: String {
        return "\(code): \(customMessage)"
    }
}
