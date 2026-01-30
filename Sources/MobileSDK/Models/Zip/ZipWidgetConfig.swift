//
//  ZipWidgetConfig.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

/**
 * Configuration for the Zip payment widget.
 *
 * This class holds all the required and optional parameters needed to initialize
 * a Zip payment session, including customer information, order details, and
 * billing/shipping addresses.
 */
public struct ZipWidgetConfig {
    /// The access token used for authenticating with the Paydock API.
    public let accessToken: String
    /// The gateway ID for processing Zip payments.
    public let gatewayId: String
    /// The total amount for the transaction.
    public let amount: Decimal
    /// The currency code (e.g., "AUD") for the transaction.
    public let currency: String
    /// Optional first name of the shopper.
    public let firstName: String?
    /// Optional last name of the shopper.
    public let lastName: String?
    /// Optional email address of the shopper.
    public let email: String?
    /// Optional phone number of the shopper.
    public let phone: String?
    /// Optional whether to tokenize the payment method (default: true).
    public let tokenize: Bool?
    /// Optional gender of the shopper ("male", "female", or other).
    public let gender: String?
    /// Optional date of birth in format "YYYY-MM-DD".
    public let dateOfBirth: String?
    /// Optional shipping type (e.g., "delivery", "pickup").
    public let shippingType: String?
    /// Optional billing address information.
    public let billing: Address?
    /// Optional shipping address information.
    public let shipping: Address?
    /// Optional list of items in the order.
    public let items: [Item]?
    /// Optional statistics about the customer's account.
    public let statistics: Statistics?

    public init(accessToken: String,
                gatewayId: String,
                amount: Decimal,
                currency: String,
                firstName: String? = nil,
                lastName: String? = nil,
                email: String? = nil,
                phone: String? = nil,
                tokenize: Bool? = true,
                gender: String? = nil,
                dateOfBirth: String? = nil,
                shippingType: String? = nil,
                billing: Address? = nil,
                shipping: Address? = nil,
                items: [Item]? = nil,
                statistics: Statistics? = nil) {
        self.accessToken = accessToken
        self.gatewayId = gatewayId
        self.amount = amount
        self.currency = currency
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.tokenize = tokenize
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.shippingType = shippingType
        self.billing = billing
        self.shipping = shipping
        self.items = items
        self.statistics = statistics
    }

    /**
     * Represents an item in the order.
     *
     * @property name The name of the item.
     * @property amount The price of the item.
     * @property quantity The quantity of the item.
     * @property reference Optional reference or description for the item.
     */
    public struct Item {
        public let name: String
        public let amount: String
        public let quantity: Int
        public let reference: String?

        public init(name: String,
                    amount: String,
                    quantity: Int,
                    reference: String? = nil) {
            self.name = name
            self.amount = amount
            self.quantity = quantity
            self.reference = reference
        }
    }

    /**
     * Represents an address for billing or shipping purposes.
     *
     * @property firstName Optional first name associated with the address.
     * @property lastName Optional last name associated with the address.
     * @property line1 Optional first line of the street address.
     * @property line2 Optional second line of the street address.
     * @property city Optional city name.
     * @property state Optional state or province.
     * @property postcode Optional postal or ZIP code.
     * @property country Optional ISO country code (e.g., "AU").
     */
    public struct Address {
        public let firstName: String?
        public let lastName: String?
        public let line1: String?
        public let line2: String?
        public let city: String?
        public let state: String?
        public let postcode: String?
        public let country: String?

        public init(firstName: String? = nil,
                    lastName: String? = nil,
                    line1: String? = nil,
                    line2: String? = nil,
                    city: String? = nil,
                    state: String? = nil,
                    postcode: String? = nil,
                    country: String? = nil) {
            self.firstName = firstName
            self.lastName = lastName
            self.line1 = line1
            self.line2 = line2
            self.city = city
            self.state = state
            self.postcode = postcode
            self.country = country
        }
    }

    /**
     * Represents customer statistics for fraud prevention.
     *
     * @property accountCreated Date when the account was created (YYYY-MM-DD).
     * @property salesTotalNumber Total number of sales.
     * @property salesTotalAmount Total amount of sales.
     * @property salesAvgValue Average value of sales.
     * @property salesMaxValue Maximum value of sales.
     * @property refundsTotalAmount Total amount of refunds.
     * @property previousChargeback Whether there was a previous chargeback.
     * @property currency Currency code.
     * @property lastLogin Date of last login (YYYY-MM-DD).
     */
    public struct Statistics {
        public let accountCreated: String?
        public let salesTotalNumber: String?
        public let salesTotalAmount: String?
        public let salesAvgValue: String?
        public let salesMaxValue: String?
        public let refundsTotalAmount: String?
        public let previousChargeback: String?
        public let currency: String?
        public let lastLogin: String?

        public init(accountCreated: String? = nil,
                    salesTotalNumber: String? = nil,
                    salesTotalAmount: String? = nil,
                    salesAvgValue: String? = nil,
                    salesMaxValue: String? = nil,
                    refundsTotalAmount: String? = nil,
                    previousChargeback: String? = nil,
                    currency: String? = nil,
                    lastLogin: String? = nil) {
            self.accountCreated = accountCreated
            self.salesTotalNumber = salesTotalNumber
            self.salesTotalAmount = salesTotalAmount
            self.salesAvgValue = salesAvgValue
            self.salesMaxValue = salesMaxValue
            self.refundsTotalAmount = refundsTotalAmount
            self.previousChargeback = previousChargeback
            self.currency = currency
            self.lastLogin = lastLogin
        }
    }
}
