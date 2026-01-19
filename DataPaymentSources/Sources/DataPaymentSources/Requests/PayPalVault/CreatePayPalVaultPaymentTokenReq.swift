//
//  CreatePayPalVaultPaymentTokenReq.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Request model for POST /v1/payment_sources/setup-tokens/{setupToken}/tokens
/// Used to create a PayPal Vault payment token from a setup token
public struct CreatePayPalVaultPaymentTokenReq: Codable {
    /// Gateway identifier for PayPal (required)
    public let gatewayId: String

    public init(gatewayId: String) {
        self.gatewayId = gatewayId
    }
}
