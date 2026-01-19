//
//  Standalone3DSReq.swift
//  DataStandalone3ds
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import CommonModels
import Foundation

/// Request model for POST /v1/charges/standalone-3ds (Standalone 3D Secure)
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#9d809325-2f12-440a-bf30-a71684d48552
public struct Standalone3DSReq: Codable {

    /// The amount to charge (required)
    public let amount: String

    /// Currency code (e.g., "USD", "AUD", "EUR") (required)
    public let currency: String

    /// Merchant reference for the charge (required)
    public let reference: String

    /// Customer payment data for standalone 3DS (required)
    public let customer: Standalone3DSCustomerPaymentData

    /// 3D Secure authentication data (required)
    public let data: Standalone3DSData

    public enum CodingKeys: String, CodingKey {
        case amount, currency, reference, customer
        case data = "_3ds"
    }

    public init(amount: String,
                currency: String,
                reference: String,
                customer: Standalone3DSCustomerPaymentData,
                data: Standalone3DSData) {
        self.amount = amount
        self.currency = currency
        self.reference = reference
        self.customer = customer
        self.data = data
    }
}

/// Customer payment data structure for standalone 3DS requests
public struct Standalone3DSCustomerPaymentData: Codable {
    /// Payment source for standalone 3DS (required)
    public let paymentSource: PaymentSource

    public init(paymentSource: PaymentSource) {
        self.paymentSource = paymentSource
    }
}

/// 3D Secure data structure for standalone 3DS requests
public struct Standalone3DSData: Codable {
    /// Service identifier for 3DS authentication (required)
    public let serviceId: String

    /// Authentication details for standalone 3DS (required)
    public let authentication: Standalone3DSAuthentication

    public init(serviceId: String, authentication: Standalone3DSAuthentication) {
        self.serviceId = serviceId
        self.authentication = authentication
    }
}

// Payment source structure for standalone 3DS requests
// public struct Standalone3DSPaymentSource: Codable {
//    /// Vault token for the payment source (required)
//    public let token: String
//
//    public enum CodingKeys: String, CodingKey {
//        case token = "vault_token"
//    }
//
//    public init(token: String) {
//        self.token = token
//    }
// }

/// Authentication structure for standalone 3DS requests
public struct Standalone3DSAuthentication: Codable {
    /// Authentication type (required)
    public let type: String

    /// Authentication date (required)
    public let date: String

    /// Authentication version (required)
    public let version: String

    /// Customer information for authentication (required)
    public let customer: Standalone3DSCustomer

    public init(type: String,
                date: String,
                version: String,
                customer: Standalone3DSCustomer) {
        self.type = type
        self.date = date
        self.version = version
        self.customer = customer
    }
}

/// Customer information structure for standalone 3DS authentication
public struct Standalone3DSCustomer: Codable {
    /// Customer creation timestamp (required)
    public let created: String

    /// Customer last update timestamp (required)
    public let updated: String

    /// Customer credentials last update timestamp (required)
    public let credsUpdated: String

    /// Flag indicating if the customer is marked as suspicious (required)
    public let suspicious: Bool

    /// Payment source information (required)
    public let source: Standalone3DSSource

    public init(created: String,
                updated: String,
                credsUpdated: String,
                suspicious: Bool,
                source: Standalone3DSSource) {
        self.created = created
        self.updated = updated
        self.credsUpdated = credsUpdated
        self.suspicious = suspicious
        self.source = source
    }
}

/// Payment source information structure for standalone 3DS
public struct Standalone3DSSource: Codable {
    /// Payment source creation timestamp (required)
    public let created: String

    /// List of attempt identifiers (required)
    public let attempts: [String]

    /// Card type identifier (required)
    public let cardType: String

    public init(created: String,
                attempts: [String],
                cardType: String) {
        self.created = created
        self.attempts = attempts
        self.cardType = cardType
    }
}
