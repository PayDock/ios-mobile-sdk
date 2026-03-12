//
//  InitialiseWalletChargeRes.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib
import CommonModels

/// Response model for POST /v1/charges/wallet (wallet charge initialization)
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#c6932472-8dbf-482d-9ad7-e2a59b682be0
public struct InitialiseWalletChargeRes: Codable {
    /// HTTP status code of the response
    public let status: Int

    /// Resource data containing wallet charge information
    public let resource: InitialiseWalletChargeResource

    public init(status: Int, resource: InitialiseWalletChargeResource) {
        self.status = status
        self.resource = resource
    }
}

/// Resource wrapper for wallet charge response
public struct InitialiseWalletChargeResource: Codable {
    /// Resource type identifier
    public let type: String

    /// Wallet data
    public let data: InitialiseWalletData

    public init(type: String, data: InitialiseWalletData) {
        self.type = type
        self.data = data
    }
}

/// Wallet data structure from wallet charge initialization response
public struct InitialiseWalletData: Codable {
    /// Wallet payment token
    public let token: String

    /// Charge information
    public let charge: InitialiseWalletChargeData

    public init(token: String, charge: InitialiseWalletChargeData) {
        self.token = token
        self.charge = charge
    }
}

/// Charge data structure from wallet charge initialization response
public struct InitialiseWalletChargeData: Codable {
    /// Charge unique identifier
    public let id: String

    /// Charge amount
    public let amount: Decimal

    /// Currency code (e.g., "AUD")
    public let currency: String

    /// Reference identifier for the charge (optional)
    public let reference: String?

    /// Company identifier (optional)
    public let companyId: String?

    /// Description of the charge (optional)
    public let description: String?

    /// Charge type (e.g., "financial") (optional)
    public let type: String?

    /// Charge status (e.g., "wallet_initialized")
    public let status: String

    /// Whether the charge should be captured immediately
    public let capture: Bool

    /// Authorization flag (optional)
    public let authorization: Bool?

    /// Whether this is a one-off charge (optional)
    public let oneOff: Bool?

    /// Surcharge amount (optional)
    public let amountSurcharge: Decimal?

    /// Original amount before surcharge (optional)
    public let amountOriginal: Decimal?

    /// Charge creation timestamp (optional)
    public let createdAt: String?

    /// Charge last update timestamp (optional)
    public let updatedAt: String?

    /// Schedule information (optional)
    public let schedule: InitialiseWalletSchedule?

    /// Archived flag (optional)
    public let archived: Bool?

    /// List of transactions associated with the charge
    public let transactions: [InitialiseWalletTransaction]?

    /// Customer information (optional)
    public let customer: Customer?

    /// Metadata associated with the charge (optional)
    public let meta: InitialiseWalletMeta?

    /// Shipping information (optional)
    public let shipping: InitialiseWalletShipping?

    /// Charge items (optional)
    public let items: [String]?

    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case amount
        case currency
        case reference
        case companyId = "company_id"
        case description
        case type
        case status
        case capture
        case authorization
        case oneOff = "one_off"
        case amountSurcharge = "amount_surcharge"
        case amountOriginal = "amount_original"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case schedule
        case archived
        case transactions
        case customer
        case meta
        case shipping
        case items
    }

    public init(id: String,
                amount: Decimal,
                currency: String,
                reference: String? = nil,
                companyId: String? = nil,
                description: String? = nil,
                type: String? = nil,
                status: String,
                capture: Bool,
                authorization: Bool? = nil,
                oneOff: Bool? = nil,
                amountSurcharge: Decimal? = nil,
                amountOriginal: Decimal? = nil,
                createdAt: String? = nil,
                updatedAt: String? = nil,
                schedule: InitialiseWalletSchedule? = nil,
                archived: Bool? = nil,
                transactions: [InitialiseWalletTransaction],
                customer: Customer? = nil,
                meta: InitialiseWalletMeta? = nil,
                shipping: InitialiseWalletShipping? = nil,
                items: [String]? = nil) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.reference = reference
        self.companyId = companyId
        self.description = description
        self.type = type
        self.status = status
        self.capture = capture
        self.authorization = authorization
        self.oneOff = oneOff
        self.amountSurcharge = amountSurcharge
        self.amountOriginal = amountOriginal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.schedule = schedule
        self.archived = archived
        self.transactions = transactions
        self.customer = customer
        self.meta = meta
        self.shipping = shipping
        self.items = items
    }
}

/// Wallet transaction structure
public struct InitialiseWalletTransaction: Codable {
    public init() {}
}

/// Schedule information structure for wallet charge
public struct InitialiseWalletSchedule: Codable {
    /// Whether schedule is stopped
    public let stopped: Bool

    public init(stopped: Bool = false) {
        self.stopped = stopped
    }
}

/// Metadata for wallet charge
public struct InitialiseWalletMeta: Codable {
    /// Store identifier (optional)
    public let storeId: String?

    /// Store name (optional)
    public let storeName: String?

    /// Merchant name (optional)
    public let merchantName: String?

    public init(storeId: String? = nil,
                storeName: String? = nil,
                merchantName: String? = nil) {
        self.storeId = storeId
        self.storeName = storeName
        self.merchantName = merchantName
    }
}

/// Shipping information for wallet charge
public struct InitialiseWalletShipping: Codable {
    /// Shipping options
    public let options: [InitialiseWalletShippingOption]?

    public init(options: [InitialiseWalletShippingOption]? = nil) {
        self.options = options
    }

    public enum CodingKeys: String, CodingKey {
        case options
    }
}

/// Shipping option for wallet charge
public struct InitialiseWalletShippingOption: Codable {
    // Empty array in example, structure can be expanded as needed
    public init() {}
}
