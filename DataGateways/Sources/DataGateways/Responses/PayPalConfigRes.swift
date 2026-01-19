//
//  PayPalVaultConfigRes.swift
//  DataGateways
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Response model for GET /v1/gateways/{gatewayId}/wallet-config
/// Used for retrieving PayPal client ID configuration
public struct PayPalConfigRes: Codable {
    public let status: Int
    public let resource: PayPalConfigResource
}

/// Resource with returned data for call
public struct PayPalConfigResource: Codable {
    public let type: String
    public let data: PayPalCallbackData
}

/// PayPal Vault callback data structure
public struct PayPalCallbackData: Codable {
    public let type: String
    public let mode: String
    public let credentials: Credentials
}

public struct Credentials: Codable {
    public let clientAuth: String
}
