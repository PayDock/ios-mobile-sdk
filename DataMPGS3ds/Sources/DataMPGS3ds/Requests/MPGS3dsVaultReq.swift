//
//  MPGS3dsVaultReq.swift
//  DataMPGS3ds
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import CommonModels
import Foundation

/// Request model for POST /v1/charges/3ds with vault token (Integrated 3D Secure Vault)
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#fdde4af3-24da-458b-b1b7-96cc56132a79
public struct MPGS3dsVaultReq: Codable {

    /// The amount to charge (required)
    public let amount: String

    /// Currency code (e.g., "USD", "AUD", "EUR") (required)
    public let currency: String

    /// Merchant reference for the charge (optional)
    public let reference: String?

    /// Customer information with vault payment source (required)
    public let customer: Customer

    /// 3D Secure authentication data (required)
    public let threeDS: MPGS3dsData

    public enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case reference
        case customer
        case threeDS = "_3ds"
    }

    public init(amount: String,
                currency: String,
                reference: String? = nil,
                customer: Customer,
                threeDS: MPGS3dsData) {
        self.amount = amount
        self.currency = currency
        self.reference = reference
        self.customer = customer
        self.threeDS = threeDS
    }
}

// Customer information structure for integrated 3DS vault requests
// public struct MPGS3dsVaultCustomer: Codable {
//    /// Payment source with vault token (required)
//    public let paymentSource: MPGS3dsVaultPaymentSource
//    
//    public enum CodingKeys: String, CodingKey {
//        case paymentSource = "payment_source"
//    }
//    
//    public init(paymentSource: MPGS3dsVaultPaymentSource) {
//        self.paymentSource = paymentSource
//    }
// }

// Payment source structure for integrated 3DS vault requests
// public struct MPGS3dsVaultPaymentSource: Codable {
//    /// Vault token for stored payment method (required)
//    public let vaultToken: String
//    
//    /// Gateway identifier for processing the payment (required)
//    public let gatewayId: String
//    
//    public enum CodingKeys: String, CodingKey {
//        case vaultToken = "vault_token"
//        case gatewayId = "gateway_id"
//    }
//    
//    public init(vaultToken: String, gatewayId: String) {
//        self.vaultToken = vaultToken
//        self.gatewayId = gatewayId
//    }
// }
