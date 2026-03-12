//
//  Customer.swift
//  CommonModels
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

/// Customer data structure
public struct Customer: Codable {
    /// Company identifier associated with the customer
    public let companyId: String?

    /// Customer's first name
    public let firstName: String?

    /// Customer's last name
    public let lastName: String?

    /// Customer's email address (optional)
    public let email: String?

    /// Customer's phone number
    public let phone: String?

    /// Flag indicating if expiration date checking is enabled
    public let checkExpireDate: Bool?

    /// Service configuration for the customer
    public let service: CustomerService?

    /// Transaction statistics for the customer
    public let statistics: CustomerStatistics?

    /// Flag indicating if the customer is archived
    public let archived: Bool?

    /// Customer status
    public let status: String?

    /// Singular payment source
    public let paymentSource: PaymentSource?

    /// List of payment sources associated with the customer
    public let paymentSources: [PaymentSource]?

    /// Default payment source identifier
    public let defaultSource: String?

    /// Customer unique identifier
    public let id: String?

    /// External Customer identifier
    public let externalId: String?

    /// List of payment destination identifiers
    public let paymentDestinations: [String]?

    /// Flag indicating if the customer is marked as suspicious (optional)
    public let suspicious: Bool?

    /// Last update timestamp
    public let updatedAt: String?

    /// Creation timestamp
    public let createdAt: String?

    /// Version number
    public let value: Int?

    public enum CodingKeys: String, CodingKey {
        case companyId, firstName, lastName, email, phone
        case checkExpireDate = "_checkExpireDate"
        case service = "_service"
        case statistics, archived, status, paymentSource, paymentSources, defaultSource
        case id = "_id"
        case externalId, paymentDestinations, suspicious, updatedAt, createdAt
        case value = "__v"
    }

    public init(companyId: String? = nil,
                firstName: String? = nil,
                lastName: String? = nil,
                email: String? = nil,
                phone: String? = nil,
                checkExpireDate: Bool? = nil,
                service: CustomerService? = nil,
                statistics: CustomerStatistics? = nil,
                archived: Bool? = nil,
                status: String? = nil,
                paymentSource: PaymentSource? = nil,
                paymentSources: [PaymentSource]? = nil,
                defaultSource: String? = nil,
                id: String? = nil,
                externalId: String? = nil,
                paymentDestinations: [String]? = nil,
                suspicious: Bool? = nil,
                updatedAt: String? = nil,
                createdAt: String? = nil,
                value: Int? = nil) {
        self.companyId = companyId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.checkExpireDate = checkExpireDate
        self.service = service
        self.statistics = statistics
        self.archived = archived
        self.status = status
        self.paymentSource = paymentSource
        self.paymentSources = paymentSources
        self.defaultSource = defaultSource
        self.id = id
        self.externalId = externalId
        self.paymentDestinations = paymentDestinations
        self.suspicious = suspicious
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.value = value
    }
}

/// Service configuration structure
public struct CustomerService: Codable {
    /// Default gateway identifier for the customer
    public let defaultGatewayId: String?

    public init(defaultGatewayId: String? = nil) {
        self.defaultGatewayId = defaultGatewayId
    }
}

/// Transaction statistics structure
public struct CustomerStatistics: Codable {
    /// Number of successful transactions
    public let successfulTransactions: Int?

    /// Total amount collected across all transactions
    public let totalCollectedAmount: Int?

    public init(successfulTransactions: Int? = nil, totalCollectedAmount: Int? = nil) {
        self.successfulTransactions = successfulTransactions
        self.totalCollectedAmount = totalCollectedAmount
    }
}
