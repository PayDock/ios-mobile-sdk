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
    /// Shopper's first name (optional)
    public let firstName: String?

    /// Shopper's last name (optional)
    public let lastName: String?

    /// Shopper's email address (optional)
    public let email: String?

    /// Whether to tokenize the payment source (optional)
    public let tokenize: Bool?

    /// Charge information (optional)
    public let charge: ExternalCheckoutCharge?

    public init(firstName: String? = nil,
                lastName: String? = nil,
                email: String? = nil,
                tokenize: Bool? = nil,
                charge: ExternalCheckoutCharge? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.tokenize = tokenize
        self.charge = charge
    }
}

/// External checkout charge information
public struct ExternalCheckoutCharge: Codable {
    /// Charge amount (optional)
    public let amount: Double?

    /// Currency code (optional)
    public let currency: String?

    /// Billing address (optional)
    public let billingAddress: ExternalBillingAddress?

    public init(amount: Double? = nil,
                currency: String? = nil,
                billingAddress: ExternalBillingAddress? = nil) {
        self.amount = amount
        self.currency = currency
        self.billingAddress = billingAddress
    }
}

/// External checkout billing address
public struct ExternalBillingAddress: Codable {
    public let firstName: String?
    public let lastName: String?
    public let addressLine1: String?
    public let addressCity: String?
    public let addressState: String?
    public let addressCountry: String?
    public let addressPostcode: String?

    public init(firstName: String? = nil,
                lastName: String? = nil,
                addressLine1: String? = nil,
                addressCity: String? = nil,
                addressState: String? = nil,
                addressCountry: String? = nil,
                addressPostcode: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.addressLine1 = addressLine1
        self.addressCity = addressCity
        self.addressState = addressState
        self.addressCountry = addressCountry
        self.addressPostcode = addressPostcode
    }
}
