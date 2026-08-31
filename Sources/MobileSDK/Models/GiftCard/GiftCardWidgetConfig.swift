//
//  GiftCardWidgetConfig.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

public struct GiftCardWidgetConfig {

    /// Required for tokenisation
    public let accessToken: String

    /// Whether pin should be stored
    public let storePin: Bool

    /// Specifies whether the primary button (e.g., Add) should be enabled by default.
    /// If `true`, the button is always enabled, and validation is performed upon clicking it.
    /// If `false`, the button remains disabled until all fields are valid. Defaults to `true`.
    public let activePrimaryButton: Bool

    /// Specifies whether the widget renders its own built-in primary (Add) button.
    /// If `false`, the widget hides its button entirely so a host app can supply its own trigger UI —
    /// see `GiftCardWidget`'s `submitTrigger`/`onFormValidityChange` parameters. Defaults to `true`.
    public let showSubmitButton: Bool

    public init(accessToken: String,
                storePin: Bool = true,
                activePrimaryButton: Bool = true,
                showSubmitButton: Bool = true) {
        self.accessToken = accessToken
        self.storePin = storePin
        self.activePrimaryButton = activePrimaryButton
        self.showSubmitButton = showSubmitButton
    }
}
