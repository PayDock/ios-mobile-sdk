//
//  WalletCallbackRes.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// Response model for POST /v1/charges/wallet/callback
public struct WalletCallbackRes: Codable {
    public let status: Int
    public let resource: WalletCallbackResource
}

/// Wallet resource structure
public struct WalletCallbackResource: Codable {
    public let type: String
    public let data: WalletCallbackData
}

/// Wallet callback data
public struct WalletCallbackData: Codable {
    public let refToken: String
    public let charge: WalletCharge

    public struct WalletCharge: Codable {
        public let status: String
    }
}
