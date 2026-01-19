//
//  InitialiseWalletChargeReq.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import CommonModels
import Foundation

/// Request model for POST /v1/charges/wallet (initialize wallet charge)
/// Used for wallet payment providers (e.g., Apple Pay, Google Pay, PayPal)
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#c6932472-8dbf-482d-9ad7-e2a59b682be0
public struct InitialiseWalletChargeReq: Codable {

    /// Customer information for the wallet charge (required)
    public let customer: InitialiseWalletChargeCustomer

    /// The amount to charge (required)
    public let amount: Decimal

    /// Currency code (e.g., "USD", "AUD", "EUR") (required)
    public let currency: String

    /// Merchant reference for the charge (required)
    public let reference: String

    /// Description of the charge (optional)
    public let description: String?

    /// Additional metadata for the charge (required)
    public let meta: InitialiseWalletChargeMetaData

    public init(customer: InitialiseWalletChargeCustomer,
                amount: Decimal,
                currency: String,
                reference: String,
                description: String? = nil,
                meta: InitialiseWalletChargeMetaData) {
        self.customer = customer
        self.amount = amount
        self.currency = currency
        self.reference = reference
        self.description = description
        self.meta = meta
    }
}

// Customer information structure for wallet charge initialization
public struct InitialiseWalletChargeCustomer: Codable {

    /// Customer's first name (required)
    public let firstName: String

    /// Customer's last name (required)
    public let lastName: String

    /// Customer's email address (required)
    public let email: String

    /// Customer's phone number (required)
    public let phone: String

    /// Payment source details for wallet payment (required)
    public let paymentSource: PaymentSource

    public init(firstName: String,
                lastName: String,
                email: String,
                phone: String,
                paymentSource: PaymentSource) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.paymentSource = paymentSource
    }
}

/// Metadata structure for wallet charge initialization
public struct InitialiseWalletChargeMetaData: Codable {

    /// Store name for the transaction (required)
    public let storeName: String

    /// Merchant name for the transaction (required)
    public let merchantName: String

    /// Store identifier (required)
    public let storeId: String

    /// URL to redirect to on successful payment (optional)
    public let successUrl: String?

    /// URL to redirect to on payment error (optional)
    public let errorUrl: String?

    public init(storeName: String,
                merchantName: String,
                storeId: String,
                successUrl: String? = nil,
                errorUrl: String? = nil) {
        self.storeName = storeName
        self.merchantName = merchantName
        self.storeId = storeId
        self.successUrl = successUrl
        self.errorUrl = errorUrl
    }
}
