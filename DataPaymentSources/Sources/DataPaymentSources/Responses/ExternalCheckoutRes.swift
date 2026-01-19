//
//  ExternalCheckoutRes.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Response model for POST /v1/payment_sources/external_checkout
/// Used for external checkout providers like Zip
public struct ExternalCheckoutRes: Codable {
    public let status: Int
    public let resource: ExternalCheckoutResource
}

public struct ExternalCheckoutResource: Codable {
    public let type: String
    public let data: CheckoutData
}

public struct CheckoutData: Codable {
    /// Checkout link URL
    public let link: String

    /// Checkout token for subsequent token creation
    public let token: String
}
