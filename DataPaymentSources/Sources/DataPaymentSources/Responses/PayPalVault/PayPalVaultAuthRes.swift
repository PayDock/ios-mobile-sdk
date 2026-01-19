//
//  PayPalVaultAuthRes.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Response model for PayPal Vault authentication
public struct PayPalVaultAuthRes: Codable {
    public let status: Int
    public let resource: PayPalVaultAuthResource
}

public struct PayPalVaultAuthResource: Codable {
    public let type: String
    public let data: PayPalVaultAutCallbackData
}

public struct PayPalVaultAutCallbackData: Codable {
    public let accessToken: String
    public let idToken: String
}
