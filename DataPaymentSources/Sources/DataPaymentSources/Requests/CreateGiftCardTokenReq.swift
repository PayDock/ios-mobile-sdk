//
//  CreateGiftCardTokenReq.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Request model for POST /v1/payment_sources/tokens (gift card tokenization)
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#53e6cf93-480c-4fd3-b7f0-1e9dbd8f5273
public struct CreateGiftCardTokenReq: Codable {
    /// Gift card number (required)
    public let cardNumber: String

    /// Gift card PIN (required)
    public let cardPin: String

    /// Whether to store the PIN for future use (optional)
    public let storePin: Bool

    /// Token type - always "gift_card" for gift cards
    public let type: String

    /// Card scheme identifier (e.g., "vii_giftcard")
    public let cardScheme: String

    /// Card processing network identifier
    public let cardProcessingNetwork: String

    public init(cardNumber: String,
                cardPin: String,
                storePin: Bool = false) {
        self.cardNumber = cardNumber
        self.cardPin = cardPin
        self.storePin = storePin
        self.type = "gift_card"
        self.cardScheme = "vii_giftcard"
        self.cardProcessingNetwork = "vii_giftcard"
    }
}
