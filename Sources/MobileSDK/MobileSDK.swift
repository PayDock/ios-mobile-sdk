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
}

// MARK: - Helpers

extension MobileSDK {
    public static let bundle: Bundle = .module
}
