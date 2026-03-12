//
//  CaptureChargeStandaloneReq.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import CommonModels
import Foundation

/// Request model for POST /v1/charges (capture standalone 3DS charge)
/// Used after 3DS authentication is completed
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#9448dc40-9bed-4379-a86c-6734d5601aaf
public struct CaptureChargeStandaloneReq: Codable {
    /// The amount to charge (required)
    public let amount: String

    /// Currency code (e.g., "USD", "AUD", "EUR") (required)
    public let currency: String

    /// Customer information for the charge (required)
    public let customer: Customer

    /// Description of the charge (required)
    public let description: String

    /// Merchant reference for the charge (required)
    public let reference: String

    /// 3D Secure charge identifier from authentication step (required)
    public let threeDSChargeId: String

    public enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case customer
        case description
        case reference
        case threeDSChargeId = "_3ds_charge_id"
    }

    public init(amount: String,
                currency: String,
                customer: Customer,
                description: String,
                reference: String,
                threeDSChargeId: String) {
        self.amount = amount
        self.currency = currency
        self.customer = customer
        self.description = description
        self.reference = reference
        self.threeDSChargeId = threeDSChargeId
    }
}
