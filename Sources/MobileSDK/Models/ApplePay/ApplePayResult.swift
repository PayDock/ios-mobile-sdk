//
//  ApplePayResult.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import DataPaymentSources

public struct ApplePayResult {

    public let ottToken: String
    public let cardInfo: ApplePayOTTCardInfo?
    public let shippingAddress: ApplePayOTTShipping?
    public let billingAddress: ApplePayOTTBilling?

    /// Initializes the Apple Pay result object
    /// - Parameters:
    ///   - ottToken: The OTT token created using Apple Pay Wallet
    ///   - cardInfo: Optional info on the selected user's card
    ///   - shippingAddress: Optional info on the user's shipping address
    ///   - billingAddress: Optional info on the user's billing address
    public init(ottToken: String,
                cardInfo: ApplePayOTTCardInfo? = nil,
                shippingAddress: ApplePayOTTShipping? = nil,
                billingAddress: ApplePayOTTBilling? = nil) {
        self.ottToken = ottToken
        self.cardInfo = cardInfo
        self.shippingAddress = shippingAddress
        self.billingAddress = billingAddress
    }
}
