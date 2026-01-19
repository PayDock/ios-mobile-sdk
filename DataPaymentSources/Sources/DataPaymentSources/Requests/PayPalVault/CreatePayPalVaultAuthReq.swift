//
//  CreatePayPalVaultAuthReq.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Request model for PayPal Vault authentication
/// Used for PayPal Vault session authentication
public struct CreatePayPalVaultAuthReq: Codable {
    /// Gateway identifier for PayPal (required)
    public let gatewayId: String

    public init(gatewayId: String) {
        self.gatewayId = gatewayId
    }
}
