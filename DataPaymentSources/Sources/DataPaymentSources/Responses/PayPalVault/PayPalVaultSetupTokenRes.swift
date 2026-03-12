//
//  PayPalVaultSetupTokenRes.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Response model for POST /v1/payment_sources/setup-tokens
public struct PayPalVaultSetupTokenRes: Codable {
    public let status: Int
    public let resource: PayPalVaultSetupTokenResource
}

public struct PayPalVaultSetupTokenResource: Codable {
    public let type: String
    public let data: SetupTokenData
}

public struct SetupTokenData: Codable {
    public let setupToken: String
}
