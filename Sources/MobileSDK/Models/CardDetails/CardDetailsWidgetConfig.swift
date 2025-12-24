//
//  CardDetailsWidgetConfig.swift
//  MobileSDK
//
//  Created by Ricardo Da Silva on 2024/12/29.
//

public struct CardDetailsWidgetConfig {

    public let accessToken: String
    public let gatewayId: String?
    public let collectCardholderName: Bool
    public let allowSaveCard: SaveCardConfig?
    public let schemeSupport: SupportedSchemesConfig

    public init(gatewayId: String?,
                accessToken: String,
                collectCardholderName: Bool = true,
                allowSaveCard: SaveCardConfig? = nil,
                schemeSupport: SupportedSchemesConfig = SupportedSchemesConfig()) {
        self.accessToken = accessToken
        self.gatewayId = gatewayId
        self.collectCardholderName = collectCardholderName
        self.allowSaveCard = allowSaveCard
        self.schemeSupport = schemeSupport
    }
}
