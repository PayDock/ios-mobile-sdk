//
//  CreatePaymentSourceTokenFromCheckoutReq.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Request model for POST /v1/payment_sources/tokens (from checkout token)
/// Used to create a payment source token from an external checkout token (e.g., Zip)
public struct CreatePaymentSourceTokenFromCheckoutReq: Codable {
    /// Token type - always "checkout_token"
    public let type: String

    /// Gateway identifier (required)
    public let gatewayId: String

    /// Checkout token from external provider (required)
    public let checkoutToken: String

    public init(checkoutToken: String, gatewayId: String) {
        self.type = "checkout_token"
        self.checkoutToken = checkoutToken
        self.gatewayId = gatewayId
    }
}
