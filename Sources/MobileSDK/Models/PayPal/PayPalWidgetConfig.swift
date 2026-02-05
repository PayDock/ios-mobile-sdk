//
//  PayPalWidgetConfig.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import PayPalWebPayments

public struct PayPalWidgetConfig {
    public var accessToken: String
    public var gatewayId: String
    public var requestShipping: Bool
    public var fundingSource: PayPalWebCheckoutFundingSource

    public init(accessToken: String,
                gatewayId: String,
                requestShipping: Bool = true,
                fundingSource: PayPalWebCheckoutFundingSource = .paypal) {
        self.accessToken = accessToken
        self.gatewayId = gatewayId
        self.requestShipping = requestShipping
        self.fundingSource = fundingSource
    }
}
