//
//  CardDetailsWidgetConfig.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Configuration for the Card Details Widget.
///
/// This struct defines the settings and behavior of the Card Details Widget, allowing customization of
/// cardholder information collection, action button text, save card options, and supported card schemes.
public struct CardDetailsWidgetConfig {

    /// An optional identifier for the payment gateway. If not specified, the default gateway is used. Defaults to `nil`.
    public let gatewayId: String?

    /// The access token required for authenticating widget operations. This is mandatory for all requests.
    public let accessToken: String

    /// Specifies whether the widget should prompt the user to input the cardholder's name. Defaults to `true`.
    public let collectCardholderName: Bool

    /// Configures whether users are allowed to save their card for future use. If `nil`, the save card option is disabled.
    public let allowSaveCard: SaveCardConfig?

    /// Specifies whether the security code (CVV) should be saved when tokenizing a card.
    /// If `nil`, the `store_ccv` parameter will not be sent in the tokenization request.
    /// If `true`, `store_ccv` will be set to `true`.
    /// If `false`, `store_ccv` will be set to `false`.
    public let storeSecurityCode: Bool?

    /// Configuration for supported card schemes and scheme validation behavior.
    public let schemeSupport: SupportedSchemesConfig

    /// Specifies whether the primary button (e.g., Submit) should be enabled by default.
    /// If `true`, the button is always enabled, and validation is performed upon clicking it.
    /// If `false`, the button remains disabled until all fields are valid. Defaults to `true`.
    public let activePrimaryButton: Bool

    public init(
        gatewayId: String? = nil,
        accessToken: String,
        collectCardholderName: Bool = true,
        allowSaveCard: SaveCardConfig? = nil,
        storeSecurityCode: Bool? = nil,
        schemeSupport: SupportedSchemesConfig = SupportedSchemesConfig(),
        activePrimaryButton: Bool = true
    ) {
        self.accessToken = accessToken
        self.gatewayId = gatewayId
        self.collectCardholderName = collectCardholderName
        self.allowSaveCard = allowSaveCard
        self.storeSecurityCode = storeSecurityCode
        self.schemeSupport = schemeSupport
        self.activePrimaryButton = activePrimaryButton
    }
}
