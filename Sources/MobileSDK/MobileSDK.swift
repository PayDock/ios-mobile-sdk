//
//  MobileSDK.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import PassKit
import NetworkingLib
import BinProcessing

public class MobileSDK {

    public static let shared = MobileSDK()
    private(set) var config: MobileSDKConfig?
    private let fontRegistration: FontRegistration

    // MARK: - Initialisation

    private init(fontRegistration: FontRegistration = FontRegistration()) {
        self.fontRegistration = fontRegistration
        setup()
    }

    private func setup() {
        fontRegistration.registerAllFonts()
    }

    public func configureMobileSDK(config: MobileSDKConfig) {
        self.config = config
        // Once we have setup our config, we are able to setup our networking based on the environment
        setupNetworkLayer()
        BinProcessing.startBinDataRefreshCoordinator()
        BinProcessing.triggerBinDataRefreshAtSDKInit()
    }

    private func setupNetworkLayer() {
        NetworkingLib.shared.host = Constants.baseURL
    }
}

// MARK: - Apple Pay helpers

extension MobileSDK {

    public static func createApplePayRequest(
        amount: Decimal,
        amountLabel: String,
        countryCode: String,
        currencyCode: String,
        merchantIdentifier: String,
        merchantCapabilities: PKMerchantCapability = [.capabilityCredit, .capabilityDebit, .capability3DS],
        supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex, .discover],
        requireBillingAddress: Bool = false,
        requireShippingAddress: Bool = false,
        shippingOptions: [PKShippingMethod]? = nil) -> PKPaymentRequest {
            let item = PKPaymentSummaryItem(label: amountLabel, amount: amount as NSDecimalNumber, type: .final)
            let paymentRequest = PKPaymentRequest()
            paymentRequest.paymentSummaryItems = [item]
            paymentRequest.countryCode = countryCode
            paymentRequest.currencyCode = currencyCode
            paymentRequest.merchantIdentifier = merchantIdentifier
            paymentRequest.merchantCapabilities = merchantCapabilities
            paymentRequest.supportedNetworks = supportedNetworks
            paymentRequest.requiredBillingContactFields = requireBillingAddress ? [.name, .postalAddress] : []
            paymentRequest.requiredShippingContactFields = requireShippingAddress
                ? [.phoneNumber, .emailAddress, .postalAddress, .name]
                : []
            paymentRequest.shippingMethods = shippingOptions
            return paymentRequest
    }

    // MARK: - Apple Pay availability

    /// Returns whether the device hardware can make Apple Pay payments, regardless of whether any
    /// cards are enrolled in the Wallet.
    ///
    /// This mirrors the first check performed internally by `ApplePayWidget`. Call it before
    /// constructing the widget to decide whether to offer Apple Pay at all.
    /// - Returns: `true` if the device supports Apple Pay.
    public static func deviceSupportsApplePay() -> Bool {
        PKPaymentAuthorizationController.canMakePayments()
    }

    /// Returns whether the device can make Apple Pay payments with at least one card enrolled in
    /// the Wallet for the given networks and merchant capabilities.
    ///
    /// Use this before constructing `ApplePayWidget` to determine whether the Apple Pay button
    /// would be shown. The defaults match `createApplePayRequest(...)`.
    /// - Parameters:
    ///   - supportedNetworks: The payment networks to check for an enrolled card.
    ///   - merchantCapabilities: The merchant capabilities the enrolled card must support.
    /// - Returns: `true` if Apple Pay can be used with the given networks and capabilities.
    public static func canMakeApplePayPayments(
        supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex, .discover],
        merchantCapabilities: PKMerchantCapability = [.capabilityCredit, .capabilityDebit, .capability3DS]
    ) -> Bool {
        PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: supportedNetworks,
            capabilities: merchantCapabilities
        )
    }

    /// Convenience overload that checks availability against the networks and merchant capabilities
    /// of an already-built `PKPaymentRequest` (e.g. the one you pass to `ApplePayWidgetConfig`).
    /// - Parameter request: The payment request whose `supportedNetworks` and `merchantCapabilities`
    ///   are used for the check.
    /// - Returns: `true` if Apple Pay can be used with the request's networks and capabilities.
    public static func canMakeApplePayPayments(for request: PKPaymentRequest) -> Bool {
        canMakeApplePayPayments(
            supportedNetworks: request.supportedNetworks,
            merchantCapabilities: request.merchantCapabilities
        )
    }
}

// MARK: - Helpers

extension MobileSDK {
    public static let bundle: Bundle = .module
}
