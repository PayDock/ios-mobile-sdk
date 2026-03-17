//
//  ApplePayWidgetConfig.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import PassKit

/// Configuration for Apple Pay widget
public struct ApplePayWidgetConfig {
    /// The PKPaymentRequest configured with merchant details
    public let pkPaymentRequest: PKPaymentRequest

    /// The Paydock service ID for Apple Pay
    public let serviceId: String

    /// The widget access token for API authentication
    public let accessToken: String

    public init(pkPaymentRequest: PKPaymentRequest,
                serviceId: String,
                accessToken: String) {
        self.pkPaymentRequest = pkPaymentRequest
        self.serviceId = serviceId
        self.accessToken = accessToken
    }
}
