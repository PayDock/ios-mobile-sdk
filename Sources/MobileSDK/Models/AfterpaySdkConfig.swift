//
//  AfterpaySdkConfig.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 22.04.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Afterpay
import Foundation

public struct AfterpaySdkConfig {
    public var config: AfterpayConfiguration
    public var environment: Environment
    public var options: CheckoutOptions

    public init(config: AfterpayConfiguration, environment: Environment, options: CheckoutOptions) {
        self.config = config
        self.environment = environment
        self.options = options
    }

    public struct CheckoutOptions {
        public var pickup: Bool? = nil
        public var buyNow: Bool? = nil
        public var shippingOptionRequired: Bool? = nil
        public var enableSingleShippingOptionUpdate: Bool? = nil

        public init(pickup: Bool? = nil,
                    buyNow: Bool? = nil,
                    shippingOptionRequired: Bool? = nil,
                    enableSingleShippingOptionUpdate: Bool? = nil) {
            self.pickup = pickup
            self.buyNow = buyNow
            self.shippingOptionRequired = shippingOptionRequired
            self.enableSingleShippingOptionUpdate = enableSingleShippingOptionUpdate
        }
    }

    public struct AfterpayConfiguration {
        public var minimumAmount: String? = nil
        public var maximumAmount: String
        public var currency: String
        public var language: String
        public var country: String

        public init(minimumAmount: String? = nil,
                    maximumAmount: String,
                    currency: String,
                    language: String = Locale.current.language.languageCode?.identifier ?? "en_AU",
                    country: String = Locale.current.region?.identifier ?? "AU") {
            self.minimumAmount = minimumAmount
            self.maximumAmount = maximumAmount
            self.currency = currency
            self.language = language
            self.country = country
        }
    }

}
