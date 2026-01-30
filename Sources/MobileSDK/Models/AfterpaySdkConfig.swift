//
//  AfterpaySdkConfig.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Afterpay
import Foundation

public struct AfterpaySdkConfig {
    public var environment: Environment
    public var options: CheckoutOptions

    public init(environment: Environment, options: CheckoutOptions) {
        self.environment = environment
        self.options = options
    }

    public struct CheckoutOptions {
        public var pickup: Bool?
        public var buyNow: Bool?
        public var shippingOptionRequired: Bool?
        public var enableSingleShippingOptionUpdate: Bool?

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
}
