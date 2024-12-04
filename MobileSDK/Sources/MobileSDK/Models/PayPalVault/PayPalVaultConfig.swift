//
//  PayPalVaultConfig.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 16.10.2024..
//

public struct PayPalVaultConfig {

    public let accessToken: String
    public let gatewayId: String
    public let actionText: String?
<<<<<<< HEAD
    public let widgetOptions: WidgetOptions

    public init(accessToken: String, gatewayId: String, actionText: String? = nil, widgetOptions: WidgetOptions? = nil) {
        self.accessToken = accessToken
        self.gatewayId = gatewayId
        self.actionText = actionText
        self.widgetOptions = widgetOptions ?? WidgetOptions(state: .none)
=======

    public init(accessToken: String, gatewayId: String, actionText: String? = nil) {
        self.accessToken = accessToken
        self.gatewayId = gatewayId
        self.actionText = actionText
>>>>>>> main
    }
}
