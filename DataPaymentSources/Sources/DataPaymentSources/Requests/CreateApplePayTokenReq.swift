//
//  CreateApplePayTokenReq.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Request model for POST /v1/payment_sources/tokens (Apple Pay OTT token)
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#53e6cf93-480c-4fd3-b7f0-1e9dbd8f5273
public struct CreateApplePayTokenReq: Codable {
    /// Service identifier for Apple Pay (required)
    public let serviceId: String

    /// Service type - "ApplePay" (required)
    public let serviceType: String

    /// Service group - "wallet" (required)
    public let serviceGroup: String

    /// Base64-encoded payload containing Apple Pay payment data (required)
    public let payload: String

    /// Payload format - "encrypted_string" (required)
    public let payloadFormat: String

    public init(serviceId: String,
                serviceType: String = "ApplePay",
                serviceGroup: String = "wallet",
                payload: String,
                payloadFormat: String = "encrypted_string") {
        self.serviceId = serviceId
        self.serviceType = serviceType
        self.serviceGroup = serviceGroup
        self.payload = payload
        self.payloadFormat = payloadFormat
    }
}

/// Apple Pay OTT payload structure - contains all data to be base64-encoded as payload
public struct ApplePayOTTPayload: Codable {
    public let shipping: ApplePayOTTShipping?
    public let billing: ApplePayOTTBilling?
    public let refToken: String
    public let cardInfo: ApplePayOTTCardInfo

    public init(shipping: ApplePayOTTShipping?,
                billing: ApplePayOTTBilling?,
                refToken: String,
                cardInfo: ApplePayOTTCardInfo) {
        self.shipping = shipping
        self.billing = billing
        self.refToken = refToken
        self.cardInfo = cardInfo
    }
}

public struct ApplePayOTTShipping: Codable {
    public let method: String?
    public let options: [ApplePayOTTShippingOption]?
    public let addressLine1: String?
    public let addressLine2: String?
    public let addressCountry: String?
    public let addressCity: String?
    public let addressPostcode: String?
    public let addressState: String?
    public let contact: ApplePayOTTContact?

    public init(method: String? = nil,
                options: [ApplePayOTTShippingOption]? = nil,
                addressLine1: String? = nil,
                addressLine2: String? = nil,
                addressCountry: String? = nil,
                addressCity: String? = nil,
                addressPostcode: String? = nil,
                addressState: String? = nil,
                contact: ApplePayOTTContact? = nil) {
        self.method = method
        self.options = options
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressCountry = addressCountry
        self.addressCity = addressCity
        self.addressPostcode = addressPostcode
        self.addressState = addressState
        self.contact = contact
    }
}

public struct ApplePayOTTShippingOption: Codable {
    public let id: String
    public let label: String
    public let amount: String
    public let detail: String?

    public init(id: String, label: String, amount: String, detail: String? = nil) {
        self.id = id
        self.label = label
        self.amount = amount
        self.detail = detail
    }
}

public struct ApplePayOTTBilling: Codable {
    public let addressLine1: String?
    public let addressLine2: String?
    public let addressCountry: String?
    public let addressCity: String?
    public let addressPostcode: String?
    public let addressState: String?

    public init(addressLine1: String? = nil,
                addressLine2: String? = nil,
                addressCountry: String? = nil,
                addressCity: String? = nil,
                addressPostcode: String? = nil,
                addressState: String? = nil) {
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressCountry = addressCountry
        self.addressCity = addressCity
        self.addressPostcode = addressPostcode
        self.addressState = addressState
    }
}

public struct ApplePayOTTContact: Codable {
    public let firstName: String?
    public let lastName: String?
    public let email: String?
    public let phone: String?

    public init(firstName: String? = nil,
                lastName: String? = nil,
                email: String? = nil,
                phone: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
    }
}

public struct ApplePayOTTCardInfo: Codable {
    public let cardScheme: String

    public init(cardScheme: String) {
        self.cardScheme = cardScheme
    }
}
