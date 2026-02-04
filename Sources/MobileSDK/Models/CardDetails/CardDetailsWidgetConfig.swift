//
//  CardDetailsWidgetConfig.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

public struct CardDetailsWidgetConfig {

    public let accessToken: String
    public let gatewayId: String?
    public let collectCardholderName: Bool
    public let allowSaveCard: SaveCardConfig?
    /// Specifies whether the security code (CVV) should be saved when tokenizing a card.
    /// If `nil`, the `store_ccv` parameter will not be sent in the tokenization request.
    /// If `true`, `store_ccv` will be set to `true`.
    /// If `false`, `store_ccv` will be set to `false`.
    public let storeSecurityCode: Bool?
    public let schemeSupport: SupportedSchemesConfig

    public init(gatewayId: String?,
                accessToken: String,
                collectCardholderName: Bool = true,
                allowSaveCard: SaveCardConfig? = nil,
                storeSecurityCode: Bool? = nil,
                schemeSupport: SupportedSchemesConfig = SupportedSchemesConfig()) {
        self.accessToken = accessToken
        self.gatewayId = gatewayId
        self.collectCardholderName = collectCardholderName
        self.allowSaveCard = allowSaveCard
        self.storeSecurityCode = storeSecurityCode
        self.schemeSupport = schemeSupport
    }
}
