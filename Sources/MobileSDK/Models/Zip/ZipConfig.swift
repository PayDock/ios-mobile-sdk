//
//  ZipConfig.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

public struct ZipConfig {
    public let gatewayId: String
    public let token: String
    public let amount: Decimal
    public let currency: String
    public let orderReference: String
    public let orderItems: [OrderItem]
    public let shopper: Shopper
    public let billing: Address?
    public let shipping: Address?
    public let environment: ZipEnvironment

    public init(gatewayId: String,
                token: String,
                amount: Decimal,
                currency: String,
                orderReference: String,
                orderItems: [OrderItem],
                shopper: Shopper,
                billing: Address? = nil,
                shipping: Address? = nil,
                environment: ZipEnvironment = .sandbox) {
        self.gatewayId = gatewayId
        self.token = token
        self.amount = amount
        self.currency = currency
        self.orderReference = orderReference
        self.orderItems = orderItems
        self.shopper = shopper
        self.billing = billing
        self.shipping = shipping
        self.environment = environment
    }

    public struct OrderItem {
        public let name: String
        public let amount: Decimal
        public let quantity: Int
        public let type: String?
        public let reference: String?

        public init(name: String,
                    amount: Decimal,
                    quantity: Int,
                    type: String? = nil,
                    reference: String? = nil) {
            self.name = name
            self.amount = amount
            self.quantity = quantity
            self.type = type
            self.reference = reference
        }
    }

    public struct Shopper {
        public let firstName: String
        public let lastName: String
        public let email: String
        public let phone: String?
        public let gender: String?
        public let dateOfBirth: String?

        public init(firstName: String,
                    lastName: String,
                    email: String,
                    phone: String? = nil,
                    gender: String? = nil,
                    dateOfBirth: String? = nil) {
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            self.phone = phone
            self.gender = gender
            self.dateOfBirth = dateOfBirth
        }
    }

    public struct Address {
        public let firstName: String?
        public let lastName: String?
        public let line1: String?
        public let line2: String?
        public let city: String?
        public let state: String?
        public let postalCode: String?
        public let countryCode: String?

        public init(firstName: String? = nil,
                    lastName: String? = nil,
                    line1: String? = nil,
                    line2: String? = nil,
                    city: String? = nil,
                    state: String? = nil,
                    postalCode: String? = nil,
                    countryCode: String? = nil) {
            self.firstName = firstName
            self.lastName = lastName
            self.line1 = line1
            self.line2 = line2
            self.city = city
            self.state = state
            self.postalCode = postalCode
            self.countryCode = countryCode
        }
    }
}

public enum ZipEnvironment: String {
    case sandbox
    case production
}
