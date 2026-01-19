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
                serviceType: String,
                serviceGroup: String,
                payload: String,
                payloadFormat: String) {
        self.serviceId = serviceId
        self.serviceType = serviceType
        self.serviceGroup = serviceGroup
        self.payload = payload
        self.payloadFormat = payloadFormat
    }
}

/// Apple Pay OTT payload structure
public struct ApplePayOTTPayload: Codable {
    public let shipping: ApplePayOTTShipping?
    public let billing: ApplePayOTTBilling?
    public let refToken: String
    public let cardInfo: ApplePayOTTCardInfo
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
}

public struct ApplePayOTTShippingOption: Codable {
    public let id: String
    public let label: String
    public let amount: String
    public let detail: String?
}

public struct ApplePayOTTBilling: Codable {
    public let addressLine1: String?
    public let addressLine2: String?
    public let addressCountry: String?
    public let addressCity: String?
    public let addressPostcode: String?
    public let addressState: String?
}

public struct ApplePayOTTContact: Codable {
    public let firstName: String?
    public let lastName: String?
    public let email: String?
    public let phone: String?
}

public struct ApplePayOTTCardInfo: Codable {
    public let cardScheme: String
}
