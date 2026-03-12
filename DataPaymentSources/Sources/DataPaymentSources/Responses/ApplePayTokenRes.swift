//
//  ApplePayTokenRes.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// Response model for POST /v1/payment_sources/tokens (Apple Pay)
public struct ApplePayTokenRes: Codable {
    public let status: Int
    public let resource: ApplePayTokenResource
}

public struct ApplePayTokenResource: Codable {
    public let type: String
    public let data: ApplePayTokenData
}

/// Apple Pay token data
public struct ApplePayTokenData: Codable {
    public let tempToken: String
    public let tokenType: String
}
