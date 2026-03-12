//
//  CreateExternalCheckoutReq.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Request model for POST /v1/payment_sources/external_checkout
/// Used for initializing external checkout providers like Zip
public struct CreateExternalCheckoutReq: Codable {
    /// Gateway identifier for the external checkout provider (required)
    public let gatewayId: String

    /// Metadata for the external checkout (required)
    public let meta: ExternalCheckoutMeta

    /// Success redirect URL (required)
    public let successRedirectUrl: String

    /// Error redirect URL (required)
    public let errorRedirectUrl: String

    /// Redirect URL (required)
    public let redirectUrl: String

    public init(gatewayId: String,
                meta: ExternalCheckoutMeta,
                successRedirectUrl: String,
                errorRedirectUrl: String,
                redirectUrl: String) {
        self.gatewayId = gatewayId
        self.meta = meta
        self.successRedirectUrl = successRedirectUrl
        self.errorRedirectUrl = errorRedirectUrl
        self.redirectUrl = redirectUrl
    }
}

/// External checkout metadata
public struct ExternalCheckoutMeta: Codable {
    /// Customer's first name (optional)
    public let firstName: String?

    /// Customer's last name (optional)
    public let lastName: String?

    /// Customer's email address (optional)
    public let email: String?

    /// Customer's phone number (optional)
    public let phone: String?

    /// Customer's gender (optional)
    public let gender: String?

    /// Customer's date of birth (optional)
    public let dateOfBirth: String?

    /// Whether to tokenize the payment source (optional)
    public let tokenize: Bool?

    /// Charge information (required)
    public let charge: ExternalCheckoutCharge

    /// Customer statistics for fraud prevention (optional)
    public let statistics: ExternalCheckoutStatistics?

    public init(firstName: String? = nil,
                lastName: String? = nil,
                email: String? = nil,
                phone: String? = nil,
                gender: String? = nil,
                dateOfBirth: String? = nil,
                tokenize: Bool? = nil,
                charge: ExternalCheckoutCharge,
                statistics: ExternalCheckoutStatistics? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.tokenize = tokenize
        self.charge = charge
        self.statistics = statistics
    }
}

/// External checkout charge information
public struct ExternalCheckoutCharge: Codable {
    /// Charge amount (required)
    public let amount: Decimal

    /// Currency code (required)
    public let currency: String

    /// Shipping type (optional)
    public let shippingType: String?

    /// Billing address (optional)
    public let billingAddress: ExternalBillingAddress?

    /// Shipping address (optional)
    public let shippingAddress: ExternalBillingAddress?

    /// List of items in the order (optional)
    public let items: [ExternalCheckoutItem]?

    public init(amount: Decimal,
                currency: String,
                shippingType: String? = nil,
                billingAddress: ExternalBillingAddress? = nil,
                shippingAddress: ExternalBillingAddress? = nil,
                items: [ExternalCheckoutItem]? = nil) {
        self.amount = amount
        self.currency = currency
        self.shippingType = shippingType
        self.billingAddress = billingAddress
        self.shippingAddress = shippingAddress
        self.items = items
    }
}

/// External checkout billing address
public struct ExternalBillingAddress: Codable {
    /// First name associated with the billing address (optional)
    public let firstName: String?

    /// Last name associated with the billing address (optional)
    public let lastName: String?

    /// First line of the street address (optional)
    public let addressLine1: String?

    /// Second line of the address (optional)
    public let addressLine2: String?

    /// City name (optional)
    public let addressCity: String?

    /// State or province (optional)
    public let addressState: String?

    /// Country code (optional)
    public let addressCountry: String?

    /// Postal or ZIP code (optional)
    public let addressPostcode: String?

    public init(firstName: String? = nil,
                lastName: String? = nil,
                addressLine1: String? = nil,
                addressLine2: String? = nil,
                addressCity: String? = nil,
                addressState: String? = nil,
                addressCountry: String? = nil,
                addressPostcode: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressCity = addressCity
        self.addressState = addressState
        self.addressCountry = addressCountry
        self.addressPostcode = addressPostcode
    }
}

/// External checkout item details
public struct ExternalCheckoutItem: Codable {
    /// The name of the item
    public let name: String

    /// The price of the item
    public let amount: String

    /// The quantity of the item
    public let quantity: Int

    /// Optional reference or description
    public let reference: String?

    enum CodingKeys: String, CodingKey {
        case name
        case amount
        case quantity
        case reference
    }

    public init(name: String,
                amount: String,
                quantity: Int,
                reference: String? = nil) {
        self.name = name
        self.amount = amount
        self.quantity = quantity
        self.reference = reference
    }
}

/// Customer statistics for fraud prevention
public struct ExternalCheckoutStatistics: Codable {
    /// Date when the account was created (YYYY-MM-DD)
    public let accountCreated: String?

    /// Total number of sales
    public let salesTotalNumber: String?

    /// Total amount of sales
    public let salesTotalAmount: String?

    /// Average value of sales
    public let salesAvgValue: String?

    /// Maximum value of sales
    public let salesMaxValue: String?

    /// Total amount of refunds
    public let refundsTotalAmount: String?

    /// Whether there was a previous chargeback
    public let previousChargeback: String?

    /// Currency code
    public let currency: String?

    /// Date of last login (YYYY-MM-DD)
    public let lastLogin: String?

    public init(accountCreated: String? = nil,
                salesTotalNumber: String? = nil,
                salesTotalAmount: String? = nil,
                salesAvgValue: String? = nil,
                salesMaxValue: String? = nil,
                refundsTotalAmount: String? = nil,
                previousChargeback: String? = nil,
                currency: String? = nil,
                lastLogin: String? = nil) {
        self.accountCreated = accountCreated
        self.salesTotalNumber = salesTotalNumber
        self.salesTotalAmount = salesTotalAmount
        self.salesAvgValue = salesAvgValue
        self.salesMaxValue = salesMaxValue
        self.refundsTotalAmount = refundsTotalAmount
        self.previousChargeback = previousChargeback
        self.currency = currency
        self.lastLogin = lastLogin
    }
}
