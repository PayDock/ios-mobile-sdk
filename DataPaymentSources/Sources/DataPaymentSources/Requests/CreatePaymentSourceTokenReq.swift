//
//  CreatePaymentSourceTokenReq.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

/// Request model for POST /v1/payment_sources/tokens
/// Comprehensive model supporting multiple token types: card, gift_card, checkout_token, OTT tokens, etc.
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#53e6cf93-480c-4fd3-b7f0-1e9dbd8f5273
public struct CreatePaymentSourceTokenReq: Codable {
    // MARK: - Common Fields

    /// Token type: "card", "gift_card", "checkout_token", etc. (optional)
    public let type: String?

    /// Gateway identifier for processing the token (optional)
    public let gatewayId: String?

    // MARK: - Card Tokenization Fields

    /// Card number for tokenization (optional, required for card type)
    public let cardNumber: String?

    /// Cardholder name (optional)
    public let cardName: String?

    /// Card expiration month (MM format) (optional)
    public let expireMonth: String?

    /// Card expiration year (YYYY format) (optional)
    public let expireYear: String?

    /// Card CVV/CVC code (optional)
    public let cardCcv: String?

    /// Whether to store the CVV for future use (optional)
    public let storeCcv: Bool?

    /// Whether the user has accepted consent to save the card (optional)
    /// This value reflects the save card toggle state in the widget UI.
    /// It is `true` when the save card toggle is enabled, `false` when disabled.
    public let savedCardConsentAccepted: Bool?

    // MARK: - Gift Card Fields

    /// Gift card PIN (optional, required for gift_card type)
    public let cardPin: String?

    /// Whether to store the PIN for future use (optional)
    public let storePin: Bool?

    /// Card scheme identifier (e.g., "vii_giftcard") (optional)
    public let cardScheme: String?

    /// Card processing network identifier (optional)
    public let cardProcessingNetwork: String?

    // MARK: - Checkout Token Fields

    /// Checkout token from external payment providers (optional, required for checkout_token type)
    public let checkoutToken: String?

    // MARK: - OTT Token Fields (Apple Pay, Google Pay, etc.)

    /// Service identifier for wallet payments (optional, required for OTT tokens)
    public let serviceId: String?

    /// Service type (e.g., "ApplePay", "GooglePay") (optional)
    public let serviceType: String?

    /// Service group (e.g., "wallet") (optional)
    public let serviceGroup: String?

    /// Base64-encoded payload containing payment data (optional, required for OTT tokens)
    public let payload: String?

    /// Payload format (e.g., "encrypted_string") (optional)
    public let payloadFormat: String?

    // MARK: - Additional Fields

    /// Additional metadata as key-value pairs (optional)
    public let meta: [String: String]?

    // MARK: - Initialisation

    public init(type: String? = nil,
                gatewayId: String? = nil,
                cardNumber: String? = nil,
                cardName: String? = nil,
                expireMonth: String? = nil,
                expireYear: String? = nil,
                cardCcv: String? = nil,
                storeCcv: Bool? = nil,
                savedCardConsentAccepted: Bool? = nil,
                cardPin: String? = nil,
                storePin: Bool? = nil,
                cardScheme: String? = nil,
                cardProcessingNetwork: String? = nil,
                checkoutToken: String? = nil,
                serviceId: String? = nil,
                serviceType: String? = nil,
                serviceGroup: String? = nil,
                payload: String? = nil,
                payloadFormat: String? = nil,
                meta: [String: String]? = nil) {
        self.type = type
        self.gatewayId = gatewayId
        self.cardNumber = cardNumber
        self.cardName = cardName
        self.expireMonth = expireMonth
        self.expireYear = expireYear
        self.cardCcv = cardCcv
        self.storeCcv = storeCcv
        self.savedCardConsentAccepted = savedCardConsentAccepted
        self.cardPin = cardPin
        self.storePin = storePin
        self.cardScheme = cardScheme
        self.cardProcessingNetwork = cardProcessingNetwork
        self.checkoutToken = checkoutToken
        self.serviceId = serviceId
        self.serviceType = serviceType
        self.serviceGroup = serviceGroup
        self.payload = payload
        self.payloadFormat = payloadFormat
        self.meta = meta
    }
}
