//
//  MobileSDK.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 05.07.2023..
//

import Foundation
import PassKit
import NetworkingLib

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
    }
    
    private func setupNetworkLayer() {
        // Check if test mode is not enabled, then set the public key hash
        if config?.enableTestMode == false {
            NetworkingLib.shared.publicKeyHash = Constants.sslPublicKeyHash
        } else {
            // Optionally, you can clear or reset the publicKeyHash when test mode is enabled
            NetworkingLib.shared.publicKeyHash = nil
        }
        
        // Set the host regardless of the test mode
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
