//
//  CardDetailsWidgetConfig.swift
//  MobileSDK
//
//  Created by Ricardo Da Silva on 2024/12/29.
//

public struct CardDetailsWidgetConfig {

    public let accessToken: String
    public let gatewayId: String?
    public let actionText: String
    public let showCardTitle: Bool
    public let collectCardholderName: Bool
    public let allowSaveCard: SaveCardConfig?
    public let schemeSupport: SupportedSchemesConfig

    public init(
        gatewayId: String?,
        accessToken: String,
        actionText: String = "Submit",
        showCardTitle: Bool = true,
        collectCardholderName: Bool = true,
        allowSaveCard: SaveCardConfig? = nil,
        schemeSupport: SupportedSchemesConfig = SupportedSchemesConfig()
    ) {
        self.accessToken = accessToken
        self.gatewayId = gatewayId
        self.actionText = actionText
        self.showCardTitle = showCardTitle
        self.collectCardholderName = collectCardholderName
        self.allowSaveCard = allowSaveCard
        self.schemeSupport = schemeSupport
    }
}
