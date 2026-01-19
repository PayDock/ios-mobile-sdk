//
//  PayPalVaultPaymentTokenRes.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Response model for POST /v1/payment_sources/setup-tokens/{setupToken}/tokens
public struct PayPalVaultPaymentTokenRes: Codable {
    public let status: Int
    public let resource: Resource
}

public struct Resource: Codable {
    public let type: String
    public let data: PaymentTokenData
}

public struct PaymentTokenData: Codable {
    public let token: String
    public let email: String
}
