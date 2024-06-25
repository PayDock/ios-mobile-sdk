//
//  MastercardDpaOptions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public struct MastercardDpaOptions: Codable {
    public var dpaBillingPreference: MastercardDPAShippingBillingPreference?
    public var paymentOptions: [PaymentOption]?
    public var orderType: MastercardOrderType?
    public var threeDSPreference: String?
    public var confirmPayment: Bool?

    public init(dpaBillingPreference: MastercardDPAShippingBillingPreference? = nil,
                paymentOptions: [PaymentOption]? = nil,
                orderType: MastercardOrderType? = nil,
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
