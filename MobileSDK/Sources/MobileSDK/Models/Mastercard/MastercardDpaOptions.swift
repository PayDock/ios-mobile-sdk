//
//  MastercardDpaOptions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public struct MastercardDpaOptions: Codable {
    public let dpaBillingPreference: MastercardDPAShippingBillingPreference? = nil
    public let paymentOptions: [PaymentOption]? = nil
    public let orderType: MastercardOrderType? = nil
    public let threeDSPreference: String? = nil
    public let confirmPayment: Bool? = nil

    enum CodingKeys: String, CodingKey {
        case dpaBillingPreference = "dpa_billing_preference"
        case paymentOptions = "payment_options"
        case orderType = "order_type"
        case threeDSPreference = "three_ds_preference"
        case confirmPayment = "confirm_payment"
    }
}
