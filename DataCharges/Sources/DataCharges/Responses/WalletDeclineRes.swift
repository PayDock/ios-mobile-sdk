//
//  WalletDeclineRes.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Response model for POST /v1/charges/wallet/{chargeId}/decline
public struct WalletDeclineRes: Codable {
    public let status: Int
    public let resource: WalletDeclineResource
}

/// Resource model with returned data
public struct WalletDeclineResource: Codable {
    public let data: WalletDeclineData
}

public struct WalletDeclineData: Codable {
    public let status: String
}
