//
//  WalletCaptureRes.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Response model for POST /v1/charges/wallet/capture
public struct WalletCaptureRes: Codable {
    public let status: Int
    public let resource: WalletCaptureResource
}

/// Resource model with returned data
public struct WalletCaptureResource: Codable {
    public let type: String
    public let data: WalletCaptureChargeData
}

/// Wallet charge data from capture response
public struct WalletCaptureChargeData: Codable {
    public let status: String
    public let amount: Decimal
    public let currency: String
}
