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
    public let showSetUpButtonWhenNoCardsEnrolled: Bool

    public init(serviceId: String,
                accessToken: String,
                pkPaymentRequest: PKPaymentRequest,
                showSetUpButtonWhenNoCardsEnrolled: Bool = false) {
        self.serviceId = serviceId
        self.accessToken = accessToken
        self.pkPaymentRequest = pkPaymentRequest
        self.showSetUpButtonWhenNoCardsEnrolled = showSetUpButtonWhenNoCardsEnrolled
    }
}
