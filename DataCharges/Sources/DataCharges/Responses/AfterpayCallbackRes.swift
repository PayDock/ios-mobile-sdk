//
//  AfterpayCallbackRes.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// Response model for POST /v1/charges/wallet/callback (Afterpay)
public struct AfterpayCallbackRes: Codable {
    public let status: Int
    public let resource: AfterpayResource
}

/// Afterpay resource structure
public struct AfterpayResource: Codable {
    public let type: String
    public let data: AfterpayWalletData
}

/// Afterpay wallet data
public struct AfterpayWalletData: Codable {
    public let refToken: String
    public let charge: AfterPayCharge
}

public struct AfterPayCharge: Codable {
    public let status: String
}
