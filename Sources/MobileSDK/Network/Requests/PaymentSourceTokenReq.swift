//
//  PaymentSourceTokenReq.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

struct PaymentSourceTokenReq: Codable {
    let type: String
    let gatewayId: String
    let checkoutToken: String

    enum CodingKeys: String, CodingKey {
        case type
        case gatewayId = "gateway_id"
        case checkoutToken = "checkout_token"
    }

    init(checkoutToken: String, gatewayId: String) {
        self.type = "checkout_token"
        self.checkoutToken = checkoutToken
        self.gatewayId = gatewayId
    }
}
