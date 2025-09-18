//
//  PayPalWidgetConfig.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 14.09.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

public struct PayPalWidgetConfig {
    public var accessToken: String
    public var gatewayId: String
    public var requestShipping: Bool

    public init(accessToken: String,
                gatewayId: String,
                requestShipping: Bool = true) {
        self.accessToken = accessToken
        self.gatewayId = gatewayId
        self.requestShipping = requestShipping
    }
}
