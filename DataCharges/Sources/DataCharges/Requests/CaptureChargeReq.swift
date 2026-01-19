//
//  CaptureChargeReq.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import CommonModels

/// Request model for POST /v1/charges
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#9448dc40-9bed-4379-a86c-6734d5601aaf
public struct CaptureChargeReq: Codable {
    /// The amount to charge (required)
    public let amount: String

    /// Currency code (e.g., "USD", "AUD", "EUR") (required)
    public let currency: String

    /// Merchant reference for the charge (optional)
    public let reference: String?

    /// Description of the charge (optional)
    public let description: String?

    /// One-time token (OTT) or payment source token (optional)
    public let token: String?

    /// Customer information including payment source details (optional)
    public let customer: Customer?

    /// Shipping address information (optional)
    public let shipping: ChargeShippingAddress?

    /// 3D Secure authentication data (optional)
    public let threeDS: Charge3DSData?

    /// Additional metadata for the charge (optional)
    public let meta: ChargeMeta?

    public enum CodingKeys: String, CodingKey {
        case amount, currency, reference, description, token, customer, shipping, meta
        case threeDS = "_3ds"
    }

    public init(amount: String,
                currency: String,
                reference: String? = nil,
                description: String? = nil,
                token: String? = nil,
                customer: Customer? = nil,
                shipping: ChargeShippingAddress? = nil,
                threeDS: Charge3DSData? = nil,
                meta: ChargeMeta? = nil) {
        self.amount = amount
        self.currency = currency
        self.reference = reference
        self.description = description
        self.token = token
        self.customer = customer
        self.shipping = shipping
        self.threeDS = threeDS
        self.meta = meta
    }
}

/// Shipping address information structure for charge requests
public struct ChargeShippingAddress: Codable {
    /// Shipping contact's first name (optional)
    public let firstName: String?

    /// Shipping contact's last name (optional)
    public let lastName: String?

    /// Shipping address line 1 (optional)
    public let addressLine1: String?

    /// Shipping address line 2 (optional)
    public let addressLine2: String?

    /// Shipping address line 3 (optional)
    public let addressLine3: String?

    /// Shipping address city (optional)
    public let addressCity: String?

    /// Shipping address state or province (optional)
    public let addressState: String?

    /// Shipping address postal code (optional)
    public let addressPostcode: String?

    /// Shipping address country code (ISO 3166-1 alpha-2) (optional)
    public let addressCountry: String?

    /// Shipping contact's phone number (optional)
    public let phone: String?

    /// Shipping contact's email address (optional)
    public let email: String?

    public init(firstName: String? = nil,
                lastName: String? = nil,
                addressLine1: String? = nil,
                addressLine2: String? = nil,
                addressLine3: String? = nil,
                addressCity: String? = nil,
                addressState: String? = nil,
                addressPostcode: String? = nil,
                addressCountry: String? = nil,
                phone: String? = nil,
                email: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressLine3 = addressLine3
        self.addressCity = addressCity
        self.addressState = addressState
        self.addressPostcode = addressPostcode
        self.addressCountry = addressCountry
        self.phone = phone
        self.email = email
    }
}

/// 3D Secure authentication data structure for charge requests
public struct Charge3DSData: Codable {
    /// 3D Secure authentication identifier (optional)
    public let id: String?

    /// Charge identifier associated with 3DS authentication (optional)
    public let chargeId: String?

    public init(id: String? = nil, chargeId: String? = nil) {
        self.id = id
        self.chargeId = chargeId
    }
}

/// Metadata structure for charge requests
public struct ChargeMeta: Codable {
    /// Store name for the transaction (optional)
    public let storeName: String?

    /// Merchant name for the transaction (optional)
    public let merchantName: String?

    /// Store identifier (optional)
    public let storeId: String?

    /// URL to redirect to on successful payment (optional)
    public let successUrl: String?

    /// URL to redirect to on payment error (optional)
    public let errorUrl: String?

    /// Order identifier (optional)
    public let orderId: String?

    /// Order number (optional)
    public let orderNumber: String?

    /// Custom key-value pairs for additional metadata (optional)
    public let customFields: [String: String]?

    public init(storeName: String? = nil,
                merchantName: String? = nil,
                storeId: String? = nil,
                successUrl: String? = nil,
                errorUrl: String? = nil,
                orderId: String? = nil,
                orderNumber: String? = nil,
                customFields: [String: String]? = nil) {
        self.storeName = storeName
        self.merchantName = merchantName
        self.storeId = storeId
        self.successUrl = successUrl
        self.errorUrl = errorUrl
        self.orderId = orderId
        self.orderNumber = orderNumber
        self.customFields = customFields
    }
}
