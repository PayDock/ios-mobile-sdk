//
//  PayPalCallbackRes.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Response model for POST /v1/charges/wallet/callback (PayPal)
public struct PayPalCallbackRes: Codable {
    public let status: Int
    public let resource: PayPalCallbackResource
}

/// PayPal resource structure
public struct PayPalCallbackResource: Codable {
    public let type: String
    public let data: PayPalCallbackData
}

/// PayPal order id data
public struct PayPalCallbackData: Codable {
    public let id: String
}
