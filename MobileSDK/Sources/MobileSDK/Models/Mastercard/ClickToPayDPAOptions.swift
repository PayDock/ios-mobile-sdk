//
//  MastercardDpaOptions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public struct ClickToPayDPAOptions: Codable {
    public var dpaBillingPreference: ClickToPayDPAShippingBillingPreference?
    public var paymentOptions: [PaymentOption]?
    public var orderType: ClickToPayOrderType?
    public var threeDSPreference: String?
    public var confirmPayment: Bool?

    public init(dpaBillingPreference: ClickToPayDPAShippingBillingPreference? = nil,
                paymentOptions: [PaymentOption]? = nil,
                orderType: ClickToPayOrderType? = nil,
                threeDSPreference: String? = nil,
                confirmPayment: Bool? = nil) {
        self.dpaBillingPreference = dpaBillingPreference
        self.paymentOptions = paymentOptions
        self.orderType = orderType
        self.threeDSPreference = threeDSPreference
        self.confirmPayment = confirmPayment
    }

    enum CodingKeys: String, CodingKey {
        case dpaBillingPreference = "dpa_billing_preference"
        case paymentOptions = "payment_options"
        case orderType = "order_type"
        case threeDSPreference = "three_ds_preference"
        case confirmPayment = "confirm_payment"
    }
}
