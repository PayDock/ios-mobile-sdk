//
//  CreatePayPalVaultSetupTokenReq.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Request model for POST /v1/payment_sources/setup-tokens
/// Used to create a PayPal Vault setup token
public struct CreatePayPalVaultSetupTokenReq: Codable {
    /// Gateway identifier for PayPal (required)
    public let gatewayId: String

    /// Return URL for PayPal callback (required)
    public let returnUrl: String

    /// Cancel URL for PayPal callback (required)
    public let cancelUrl: String

    public init(gatewayId: String,
                returnUrl: String = "sdk.ios.paypal://vault/success",
                cancelUrl: String = "sdk.ios.paypal://vault/cancel") {
        self.gatewayId = gatewayId
        self.returnUrl = returnUrl
        self.cancelUrl = cancelUrl
    }
}
