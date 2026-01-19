//
//  PaymentSource.swift
//  CommonModels
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Payment source information structure shared across multiple API requests
/// Used in charge requests, customer creation, and other payment operations
public struct PaymentSource: Codable {
    /// Payment source type
    public let type: String?

    /// Wallet payment source type
    public let walletType: String?

    /// Checkout holder name
    public let checkoutHolder: String?

    /// Checkout email address
    public let checkoutEmail: String?

    /// Vault token for stored payment methods (optional)
    public let vaultToken: String?

    /// Vault type (optional)
    public let vaultType: String?

    /// Payment method identifier (optional)
    public let paymentMethodId: String?

    /// External payer identifier from payment provider
    public let externalPayerId: String?

    /// Payment source status
    public let status: String?

    /// Gateway identifier
    public let gatewayId: String?

    /// Gateway name
    public let gatewayName: String?

    /// Gateway type
    public let gatewayType: String?

    /// Gateway mode
    public let gatewayMode: String?

    /// Creation timestamp
    public let createdAt: String?

    /// Last update timestamp
    public let updatedAt: String?

    /// Reference token from wallet providers
    public let refToken: String?

    /// Billing address line 1 (optional)
    public let addressLine1: String?

    /// Billing address line 2 (optional)
    public let addressLine2: String?

    /// Billing address line 3 (optional)
    public let addressLine3: String?

    /// Billing address city (optional)
    public let addressCity: String?

    /// Billing address state or province (optional)
    public let addressState: String?

    /// Billing address postal code (optional)
    public let addressPostcode: String?

    /// Billing address country code (ISO 3166-1 alpha-2) (optional)
    public let addressCountry: String?

    /// Last 4 digits of card number (optional)
    public let cardNumberLast4: String?

    /// Card BIN (first 6-8 digits) (optional)
    public let cardNumberBin: String?

    /// Cardholder name (optional)
    public let cardName: String?

    /// Card funding method (optional)
    public let cardFundingMethod: String?

    /// Card scheme (e.g., "visa", "mastercard") (optional)
    public let cardScheme: String?

    /// Card expiration month (optional)
    public let expireMonth: Int?

    /// Card expiration year (optional)
    public let expireYear: Int?

    /// Payment source unique identifier
    public let id: String?

    public enum CodingKeys: String, CodingKey {
        case type, walletType, checkoutHolder, checkoutEmail, vaultToken, vaultType, paymentMethodId
        case externalPayerId, status, gatewayId, gatewayName, gatewayType, gatewayMode, createdAt
        case updatedAt, refToken, addressLine1, addressLine2, addressLine3, addressCity, addressState
        case addressPostcode, addressCountry, cardNumberLast4, cardNumberBin, cardName, cardFundingMethod
        case cardScheme, expireMonth, expireYear
        case id = "_id"
    }

    public init(type: String? = nil,
                walletType: String? = nil,
                checkoutHolder: String? = nil,
                checkoutEmail: String? = nil,
                vaultToken: String? = nil,
                vaultType: String? = nil,
                paymentMethodId: String? = nil,
                externalPayerId: String? = nil,
                status: String? = nil,
                gatewayId: String? = nil,
                gatewayName: String? = nil,
                gatewayType: String? = nil,
                gatewayMode: String? = nil,
                createdAt: String? = nil,
                updatedAt: String? = nil,
                refToken: String? = nil,
                addressLine1: String? = nil,
                addressLine2: String? = nil,
                addressLine3: String? = nil,
                addressCity: String? = nil,
                addressState: String? = nil,
                addressPostcode: String? = nil,
                addressCountry: String? = nil,
                cardNumberLast4: String? = nil,
                cardNumberBin: String? = nil,
                cardName: String? = nil,
                cardFundingMethod: String? = nil,
                cardScheme: String? = nil,
                expireMonth: Int? = nil,
                expireYear: Int? = nil,
                id: String? = nil) {
        self.type = type
        self.walletType = walletType
        self.checkoutHolder = checkoutHolder
        self.checkoutEmail = checkoutEmail
        self.vaultToken = vaultToken
        self.vaultType = vaultType
        self.paymentMethodId = paymentMethodId
        self.externalPayerId = externalPayerId
        self.status = status
        self.gatewayId = gatewayId
        self.gatewayName = gatewayName
        self.gatewayType = gatewayType
        self.gatewayMode = gatewayMode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.refToken = refToken
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressLine3 = addressLine3
        self.addressCity = addressCity
        self.addressState = addressState
        self.addressPostcode = addressPostcode
        self.addressCountry = addressCountry
        self.cardNumberLast4 = cardNumberLast4
        self.cardNumberBin = cardNumberBin
        self.cardName = cardName
        self.cardFundingMethod = cardFundingMethod
        self.cardScheme = cardScheme
        self.expireMonth = expireMonth
        self.expireYear = expireYear
        self.id = id
    }
}
