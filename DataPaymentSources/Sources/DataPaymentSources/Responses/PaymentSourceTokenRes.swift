//
//  PaymentSourceTokenRes.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// Response model for POST /v1/payment_sources/tokens
/// Generic response for payment source token creation (card, gift card, checkout token)
public struct PaymentSourceTokenRes: Codable {
    public let status: Int
    public let resource: PaymentSourceTokenResource
}

public struct PaymentSourceTokenResource: Codable {
    public let type: String
    public let data: String
}
