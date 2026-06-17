//
//  ApplePayWidgetConfig.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import PassKit

/// Configuration for Apple Pay widget
public struct ApplePayWidgetConfig {

    /// The Paydock service ID for Apple Pay
    public let serviceId: String

    /// The widget access token for API authentication
    public let accessToken: String

    /// The PKPaymentRequest configured with merchant details
    public let pkPaymentRequest: PKPaymentRequest

    /// Whether to show setup button if no cards configured in wallet for default networks
    /// Otherwise an error will be fired
    public let showSetUpButtonWhenNoCardsEnrolled: Bool

    /// Whether the widget performs its own Apple Pay availability checks before showing the button.
    ///
    /// When `true` (default) the widget verifies device support and enrolled-card availability,
    /// showing the pay button, the setup button, or firing an availability error as appropriate.
    ///
    /// Set to `false` if you've already verified support yourself (e.g. via
    /// `MobileSDK.canMakeApplePayPayments(...)`) — the widget then skips its internal checks and
    /// renders the pay button directly, and no availability errors are fired.
    public let performAvailabilityChecks: Bool

    public init(serviceId: String,
                accessToken: String,
                pkPaymentRequest: PKPaymentRequest,
                showSetUpButtonWhenNoCardsEnrolled: Bool = false,
                performAvailabilityChecks: Bool = true) {
        self.serviceId = serviceId
        self.accessToken = accessToken
        self.pkPaymentRequest = pkPaymentRequest
        self.showSetUpButtonWhenNoCardsEnrolled = showSetUpButtonWhenNoCardsEnrolled
        self.performAvailabilityChecks = performAvailabilityChecks
    }
}
