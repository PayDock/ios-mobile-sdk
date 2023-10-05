//
//  MobileSDK.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 05.07.2023..
//

import Foundation
import PassKit

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
        merchantCapabilities: PKMerchantCapability = [.credit, .debit, .threeDSecure],
        supportedNetworks: [PKPaymentNetwork] = [.visa, .masterCard, .amex, .discover],
        requireBillingAddress: Bool = true,
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
            paymentRequest.requiredShippingContactFields = requireShippingAddress ? [.phoneNumber, .emailAddress, .postalAddress, .name] : []
            paymentRequest.shippingMethods = shippingOptions
            return paymentRequest
    }
}
