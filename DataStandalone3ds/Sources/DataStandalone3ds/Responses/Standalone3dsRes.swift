//
//  Standalone3dsRes.swift
//  DataStandalone3ds
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.
// swiftlint:disable file_length
import Foundation
import NetworkingLib
import CommonModels

/// Response model for POST /v1/charges/standalone-3ds (Standalone 3D Secure)
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#9d809325-2f12-440a-bf30-a71684d48552
public struct Standalone3dsRes: Codable {

    /// HTTP status code of the response
    public let status: Int

    /// Resource data containing standalone 3DS authentication information
    public let resource: Standalone3dsResource

    /// Computed property to get authentication status
    public var authStatus: AuthStatus? {
        return AuthStatus(rawValue: resource.data.status)
    }

    /// Authentication status enumeration
    public enum AuthStatus: String, Codable {
        /// Authentication not supported
        case notSupported = "authentication_not_supported"
        /// Pre-authentication pending
        case pending = "pre_authentication_pending"
    }

    public init(status: Int, resource: Standalone3dsResource) {
        self.status = status
        self.resource = resource
    }
}

/// Resource wrapper for standalone 3DS response
public struct Standalone3dsResource: Codable {
    /// Resource type identifier
    public let type: String

    /// Standalone 3DS response data
    public let data: Standalone3dsResponseData

    public init(type: String, data: Standalone3dsResponseData) {
        self.type = type
        self.data = data
    }
}

/// Standalone 3DS response data structure
public struct Standalone3dsResponseData: Codable {
    /// Charge unique identifier
    public let id: String

    /// Charge amount
    public let amount: Decimal

    /// Currency code (e.g., "USD", "AUD", "EUR")
    public let currency: String

    /// Merchant reference for the charge
    public let reference: String

    /// Company identifier
    public let companyId: String

    /// Charge type
    public let type: String

    /// Authentication status
    public let status: String

    /// External identifier for the charge (optional)
    public let externalId: String?

    /// Capture flag
    public let capture: Bool

    /// Authorization flag
    public let authorization: Bool

    /// One-off payment flag
    public let oneOff: Bool

    /// Surcharge amount (optional)
    public let amountSurcharge: Decimal?

    /// Original amount (optional)
    public let amountOriginal: Decimal?

    /// Creation timestamp
    public let createdAt: String

    /// Last update timestamp
    public let updatedAt: String

    /// Shipping information (optional)
    public let shipping: Standalone3dsShipping?

    /// Schedule information (optional)
    public let schedule: Standalone3dsSchedule?

    /// Archived flag
    public let archived: Bool

    /// Fraud information (optional, empty object in responses)
    public let fraud: Standalone3dsFraud?

    /// Brand identifier (optional)
    public let brandId: String?

    /// Customer information (optional)
    public let customer: Standalone3dsCustomerResponse?

    /// Array of transactions
    public let transactions: [Standalone3dsTransaction]

    /// 3D Secure authentication details
    public let threeDS: Standalone3dsThreeDS

    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case amount
        case currency
        case reference
        case companyId
        case type
        case status
        case externalId
        case capture
        case authorization
        case oneOff
        case amountSurcharge
        case amountOriginal
        case createdAt
        case updatedAt
        case shipping
        case schedule
        case archived
        case fraud
        case brandId
        case customer
        case transactions
        case threeDS = "_3ds"
    }

    public init(id: String,
                amount: Decimal,
                currency: String,
                reference: String,
                companyId: String,
                type: String,
                status: String,
                externalId: String?,
                capture: Bool,
                authorization: Bool,
                oneOff: Bool,
                amountSurcharge: Decimal?,
                amountOriginal: Decimal?,
                createdAt: String,
                updatedAt: String,
                shipping: Standalone3dsShipping?,
                schedule: Standalone3dsSchedule?,
                archived: Bool,
                fraud: Standalone3dsFraud?,
                brandId: String?,
                customer: Standalone3dsCustomerResponse?,
                transactions: [Standalone3dsTransaction],
                threeDS: Standalone3dsThreeDS) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.reference = reference
        self.companyId = companyId
        self.type = type
        self.status = status
        self.externalId = externalId
        self.capture = capture
        self.authorization = authorization
        self.oneOff = oneOff
        self.amountSurcharge = amountSurcharge
        self.amountOriginal = amountOriginal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.shipping = shipping
        self.schedule = schedule
        self.archived = archived
        self.fraud = fraud
        self.brandId = brandId
        self.customer = customer
        self.transactions = transactions
        self.threeDS = threeDS
    }
}

/// 3DS authentication details structure for standalone 3DS
public struct Standalone3dsThreeDS: Codable {
    /// 3DS authentication identifier
    public let id: String

    /// 3DS authentication details
    public let authentication: Standalone3dsAuthenticationResponse?

    /// 3DS authentication token (optional)
    public let token: String?

    /// Service identifier (optional)
    public let serviceId: String?

    /// Service name (optional)
    public let serviceName: String?

    /// Service type (optional)
    public let serviceType: String?

    public init(id: String,
                authentication: Standalone3dsAuthenticationResponse?,
                token: String?,
                serviceId: String?,
                serviceName: String?,
                serviceType: String?) {
        self.id = id
        self.authentication = authentication
        self.token = token
        self.serviceId = serviceId
        self.serviceName = serviceName
        self.serviceType = serviceType
    }
}

/// Authentication structure from standalone 3DS response
public struct Standalone3dsAuthenticationResponse: Codable {
    /// Authentication unique identifier
    public let id: String

    /// Authentication type
    public let type: String

    /// Authentication version
    public let version: String

    /// Authentication date
    public let date: String

    /// Customer authentication information
    public let customer: Standalone3dsAuthenticationCustomer

    /// Account identifier (optional)
    public let accountId: String?

    /// Challenge type (optional)
    public let challengeType: String?

    /// Merchant name (optional)
    public let merchantName: String?

    /// Previous authentication identifier (optional)
    public let previousAuthenticationId: String?

    /// Whitelisted flag (optional)
    public let whitelisted: Bool?

    /// Authentication method (optional)
    public let method: String?

    /// Authentication data (optional)
    public let authData: String?

    /// Risk assessment information (optional)
    public let risk: Standalone3dsAuthenticationRisk?

    /// Decoupled authentication information (optional)
    public let decoupled: Standalone3dsAuthenticationDecoupled?

    /// Recurring authentication information (optional)
    public let recurring: Standalone3dsAuthenticationRecurring?

    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type
        case version
        case date
        case customer
        case accountId = "account_id"
        case challengeType = "challenge_type"
        case merchantName = "merchant_name"
        case previousAuthenticationId = "previous_authentication_id"
        case whitelisted
        case method
        case authData = "auth_data"
        case risk
        case decoupled
        case recurring
    }

    public init(id: String,
                type: String,
                version: String,
                date: String,
                customer: Standalone3dsAuthenticationCustomer,
                accountId: String?,
                challengeType: String?,
                merchantName: String?,
                previousAuthenticationId: String?,
                whitelisted: Bool?,
                method: String?,
                authData: String?,
                risk: Standalone3dsAuthenticationRisk?,
                decoupled: Standalone3dsAuthenticationDecoupled?,
                recurring: Standalone3dsAuthenticationRecurring?) {
        self.id = id
        self.type = type
        self.version = version
        self.date = date
        self.customer = customer
        self.accountId = accountId
        self.challengeType = challengeType
        self.merchantName = merchantName
        self.previousAuthenticationId = previousAuthenticationId
        self.whitelisted = whitelisted
        self.method = method
        self.authData = authData
        self.risk = risk
        self.decoupled = decoupled
        self.recurring = recurring
    }
}

/// Customer authentication information structure
public struct Standalone3dsAuthenticationCustomer: Codable {
    /// Customer creation timestamp (optional)
    public let createdAt: String?

    /// Customer update timestamp (optional)
    public let updatedAt: String?

    /// Credentials update timestamp (optional)
    public let credentialsUpdatedAt: String?

    /// Suspicious flag
    public let suspicious: Bool

    /// Payment source information (optional)
    public let paymentSource: Standalone3dsAuthenticationPaymentSource?

    /// Activity history information (optional)
    public let activityHistory: Standalone3dsAuthenticationActivityHistory?

    public enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case credentialsUpdatedAt = "credentials_updated_at"
        case suspicious
        case paymentSource = "payment_source"
        case activityHistory = "activity_history"
    }

    public init(createdAt: String? = nil,
                updatedAt: String? = nil,
                credentialsUpdatedAt: String? = nil,
                suspicious: Bool,
                paymentSource: Standalone3dsAuthenticationPaymentSource? = nil,
                activityHistory: Standalone3dsAuthenticationActivityHistory? = nil) {
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.credentialsUpdatedAt = credentialsUpdatedAt
        self.suspicious = suspicious
        self.paymentSource = paymentSource
        self.activityHistory = activityHistory
    }
}

/// Payment source information for authentication
public struct Standalone3dsAuthenticationPaymentSource: Codable {
    /// Payment source creation timestamp
    public let createdAt: String

    /// Add attempts timestamps
    public let addAttempts: [String]

    /// Card type
    public let cardType: String

    public enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case addAttempts = "add_attempts"
        case cardType = "card_type"
    }

    public init(createdAt: String,
                addAttempts: [String],
                cardType: String) {
        self.createdAt = createdAt
        self.addAttempts = addAttempts
        self.cardType = cardType
    }
}

/// Activity history information structure
public struct Standalone3dsAuthenticationActivityHistory: Codable {
    /// Number of transactions in the last day
    public let transactionsCountLastDay: Int

    /// Number of transactions in the last six months
    public let transactionsCountLastSixMonths: Int

    /// Number of transactions in the last year
    public let transactionsCountLastYear: Int

    /// Shipping address creation timestamp
    public let shippingAddressCreatedAt: String

    public init(transactionsCountLastDay: Int,
                transactionsCountLastSixMonths: Int,
                transactionsCountLastYear: Int,
                shippingAddressCreatedAt: String) {
        self.transactionsCountLastDay = transactionsCountLastDay
        self.transactionsCountLastSixMonths = transactionsCountLastSixMonths
        self.transactionsCountLastYear = transactionsCountLastYear
        self.shippingAddressCreatedAt = shippingAddressCreatedAt
    }
}

/// Risk assessment information structure
public struct Standalone3dsAuthenticationRisk: Codable {
    /// Redeem amount
    public let redeemAmount: String

    /// Redeem currency
    public let redeemCurrency: String

    /// Redeem count
    public let redeemCount: Int

    /// Pre-order date
    public let preOrderDate: String

    /// Reorder indicator
    public let reorder: String

    /// Shipping indicator
    public let shipping: String

    public init(redeemAmount: String,
                redeemCurrency: String,
                redeemCount: Int,
                preOrderDate: String,
                reorder: String,
                shipping: String) {
        self.redeemAmount = redeemAmount
        self.redeemCurrency = redeemCurrency
        self.redeemCount = redeemCount
        self.preOrderDate = preOrderDate
        self.reorder = reorder
        self.shipping = shipping
    }
}

/// Decoupled authentication information structure
public struct Standalone3dsAuthenticationDecoupled: Codable {
    /// Timeout value
    public let timeout: String

    /// Enabled flag
    public let enabled: Bool

    public init(timeout: String, enabled: Bool) {
        self.timeout = timeout
        self.enabled = enabled
    }
}

/// Recurring authentication information structure
public struct Standalone3dsAuthenticationRecurring: Codable {
    /// Expiry date
    public let expiry: String

    /// Frequency in days
    public let frequencyDays: Int

    public init(expiry: String, frequencyDays: Int) {
        self.expiry = expiry
        self.frequencyDays = frequencyDays
    }
}

/// Shipping information structure from standalone 3DS response
public struct Standalone3dsShipping: Codable {
    /// Shipping contact information (optional, can be empty object)
    public let contact: Standalone3dsShippingContact?

    /// Shipping address line 1 (optional)
    public let addressLine1: String?

    /// Shipping address line 2 (optional)
    public let addressLine2: String?

    /// Shipping address state or province (optional)
    public let addressState: String?

    /// Shipping address country code (optional)
    public let addressCountry: String?

    /// Shipping address city (optional)
    public let addressCity: String?

    /// Shipping address postal code (optional)
    public let addressPostcode: String?

    /// Shipping method (optional)
    public let method: String?

    public init(contact: Standalone3dsShippingContact?,
                addressLine1: String?,
                addressLine2: String?,
                addressState: String?,
                addressCountry: String?,
                addressCity: String?,
                addressPostcode: String?,
                method: String?) {
        self.contact = contact
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.addressState = addressState
        self.addressCountry = addressCountry
        self.addressCity = addressCity
        self.addressPostcode = addressPostcode
        self.method = method
    }
}

/// Shipping contact information structure
public struct Standalone3dsShippingContact: Codable {
    /// Contact's first name (optional)
    public let firstName: String?

    /// Contact's last name (optional)
    public let lastName: String?

    /// Contact's email address (optional)
    public let email: String?

    public init(firstName: String? = nil, lastName: String? = nil, email: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}

/// Schedule information structure
public struct Standalone3dsSchedule: Codable {
    /// Stopped flag
    public let stopped: Bool

    public init(stopped: Bool) {
        self.stopped = stopped
    }
}

/// Customer information structure from standalone 3DS response
public struct Standalone3dsCustomerResponse: Codable {
    /// Payment source details
    public let paymentSource: PaymentSource

    /// Customer's last name (optional)
    public let lastName: String?

    /// Customer's first name (optional)
    public let firstName: String?

    /// Customer's email address (optional)
    public let email: String?

    public init(paymentSource: PaymentSource,
                lastName: String? = nil,
                firstName: String? = nil,
                email: String? = nil) {
        self.paymentSource = paymentSource
        self.lastName = lastName
        self.firstName = firstName
        self.email = email
    }
}

// Payment source structure from standalone 3DS response
// public struct Standalone3dsPaymentSourceResponse: Codable {
//    /// Payment source type
//    public let type: String
//
//    /// Gateway identifier for processing the payment
//    public let gatewayId: String
//
//    /// Gateway name
//    public let gatewayName: String
//
//    /// Gateway type
//    public let gatewayType: String
//
//    /// Vault token for stored payment methods (optional)
//    public let vaultToken: String?
//
//    /// Vault type (optional)
//    public let vaultType: String?
//
//    /// Cardholder name (optional)
//    public let cardName: String?
//
//    /// Last 4 digits of card number (optional)
//    public let cardNumberLast4: String?
//
//    /// Card BIN (first 6-8 digits) (optional)
//    public let cardNumberBin: String?
//
//    /// Card scheme (e.g., "visa", "mastercard") (optional)
//    public let cardScheme: String?
//
//    /// Billing address line 1 (optional)
//    public let addressLine1: String?
//
//    /// Billing address line 2 (optional)
//    public let addressLine2: String?
//
//    /// Billing address line 3 (optional)
//    public let addressLine3: String?
//
//    /// Billing address city (optional)
//    public let addressCity: String?
//
//    /// Billing address country code (optional)
//    public let addressCountry: String?
//
//    /// Billing address state or province (optional)
//    public let addressState: String?
//
//    /// Billing address postal code (optional)
//    public let addressPostcode: String?
//
//    /// Card expiration month (optional)
//    public let expireMonth: Int?
//
//    /// Card expiration year (optional)
//    public let expireYear: Int?
//
//
//    public init(type: String,
//                gatewayId: String,
//                gatewayName: String,
//                gatewayType: String,
//                vaultToken: String?,
//                vaultType: String? = nil,
//                cardName: String?,
//                cardNumberLast4: String?,
//                cardNumberBin: String?,
//                cardScheme: String?,
//                addressLine1: String?,
//                addressLine2: String?,
//                addressLine3: String?,
//                addressCity: String?,
//                addressCountry: String?,
//                addressState: String?,
//                addressPostcode: String?,
//                expireMonth: Int?,
//                expireYear: Int?) {
//        self.type = type
//        self.gatewayId = gatewayId
//        self.gatewayName = gatewayName
//        self.gatewayType = gatewayType
//        self.vaultToken = vaultToken
//        self.vaultType = vaultType
//        self.cardName = cardName
//        self.cardNumberLast4 = cardNumberLast4
//        self.cardNumberBin = cardNumberBin
//        self.cardScheme = cardScheme
//        self.addressLine1 = addressLine1
//        self.addressLine2 = addressLine2
//        self.addressLine3 = addressLine3
//        self.addressCity = addressCity
//        self.addressCountry = addressCountry
//        self.addressState = addressState
//        self.addressPostcode = addressPostcode
//        self.expireMonth = expireMonth
//        self.expireYear = expireYear
//    }
// }

/// Transaction structure from standalone 3DS response
public struct Standalone3dsTransaction: Codable {
    /// Transaction unique identifier
    public let id: String

    /// External identifier for the transaction (optional)
    public let externalId: String?

    /// Transaction amount
    public let amount: Decimal

    /// Fee amount (optional)
    public let amountFee: Decimal?

    /// Transaction currency
    public let currency: String?

    /// Transaction type
    public let type: String?

    /// Transaction status
    public let status: String?

    /// Creation timestamp
    public let createdAt: String?

    /// Last update timestamp
    public let updatedAt: String?

    /// Include authorization flag
    public let includeAuthorization: Bool?

    /// Processed timestamp (optional)
    public let processedAt: String?

    /// 3DS information
    public let threeDS: Standalone3dsTransactionThreeDS?

    /// Service logs array
    public let serviceLogs: [String]?

    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case externalId = "external_id"
        case amount
        case amountFee = "amount_fee"
        case currency
        case type
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case includeAuthorization = "include_authorization"
        case processedAt = "processed_at"
        case threeDS = "_3ds"
        case serviceLogs = "service_logs"
    }

    public init(id: String,
                externalId: String?,
                amount: Decimal,
                amountFee: Decimal?,
                currency: String,
                type: String,
                status: String,
                createdAt: String,
                updatedAt: String,
                includeAuthorization: Bool,
                processedAt: String?,
                threeDS: Standalone3dsTransactionThreeDS,
                serviceLogs: [String]) {
        self.id = id
        self.externalId = externalId
        self.amount = amount
        self.amountFee = amountFee
        self.currency = currency
        self.type = type
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.includeAuthorization = includeAuthorization
        self.processedAt = processedAt
        self.threeDS = threeDS
        self.serviceLogs = serviceLogs
    }
}

/// Fraud information structure
public struct Standalone3dsFraud: Codable {
    // Empty structure - fraud object is empty in API responses
    // Can be extended with fields as needed when API provides fraud data

    public init() {
    }
}

/// 3DS information structure within transaction
public struct Standalone3dsTransactionThreeDS: Codable {
    // Can be extended with fields as needed when API provides 3DS data in transactions

    public init() {
    }
}
