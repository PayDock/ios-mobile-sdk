//
//  CaptureChargeRes.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib
import CommonModels

/// Response model for POST /v1/charges
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#9448dc40-9bed-4379-a86c-6734d5601aaf
public struct CaptureChargeRes: Codable {

    /// HTTP status code of the response
    public let status: Int

    /// Resource data containing charge information
    public let resource: CaptureChargeResource

    public init(status: Int, resource: CaptureChargeResource) {
        self.status = status
        self.resource = resource
    }
}

/// Resource wrapper for capture charge response
public struct CaptureChargeResource: Codable {
    /// Resource type identifier
    public let type: String

    /// Charge data
    public let data: CaptureChargeData

    public init(type: String, data: CaptureChargeData) {
        self.type = type
        self.data = data
    }
}

/// Charge data structure from capture charge response
public struct CaptureChargeData: Codable {
    /// Transfer information
    public let transfer: CaptureChargeTransfer?

    /// Schedule information
    public let schedule: CaptureChargeSchedule?

    /// Statistics information
    public let statistics: CaptureChargeStatistics?

    /// Customer information
    public let customer: Customer?

    /// Charge unique identifier
    public let id: String

    /// Charge type (e.g., "financial")
    public let type: String

    /// Charge amount
    public let amount: Decimal

    /// Currency code (e.g., "USD", "AUD", "EUR")
    public let currency: String

    /// Charge status
    public let status: String

    /// Company identifier
    public let companyId: String?

    /// Brand identifier (optional)
    public let brandId: String?

    /// Capture flag
    public let capture: Bool

    /// Authorization flag
    public let authorization: Bool

    /// Archived flag
    public let archived: Bool?

    /// Charge description (optional)
    public let description: String?

    /// One-off payment flag
    public let oneOff: Bool?

    /// Merchant reference for the charge
    public let reference: String?

    /// Charge items (optional)
    public let items: [String]?

    /// Array of transactions
    public let transactions: [CaptureChargeTransaction]?

    /// Last update timestamp
    public let updatedAt: String?

    /// Creation timestamp
    public let createdAt: String?

    /// Version number
    public let value: Int?

    /// External identifier for the charge
    public let externalId: String?

    /// Metadata information (optional)
    public let meta: CaptureChargeMeta?

    /// Logs migrated flag (optional)
    public let logsMigrated: Bool?

    /// Token identifier (optional)
    public let tokenId: String?

    public enum CodingKeys: String, CodingKey {
        case transfer
        case schedule
        case statistics
        case customer
        case type
        case amount
        case currency
        case status
        case capture
        case authorization
        case archived
        case description
        case oneOff = "one_off"
        case reference
        case items
        case transactions
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case externalId = "external_id"
        case meta
        case logsMigrated = "logs_migrated"
        case tokenId = "token_id"
        case id = "_id"
        case companyId = "company_id"
        case brandId = "brand_id"
        case value = "__v"
    }

    public init(transfer: CaptureChargeTransfer?,
                schedule: CaptureChargeSchedule?,
                statistics: CaptureChargeStatistics?,
                customer: Customer?,
                id: String,
                type: String,
                amount: Decimal,
                currency: String,
                status: String,
                companyId: String?,
                brandId: String?,
                capture: Bool,
                authorization: Bool,
                archived: Bool?,
                description: String?,
                oneOff: Bool?,
                reference: String?,
                items: [String]?,
                transactions: [CaptureChargeTransaction]?,
                updatedAt: String?,
                createdAt: String?,
                value: Int?,
                externalId: String?,
                meta: CaptureChargeMeta?,
                logsMigrated: Bool?,
                tokenId: String?) {
        self.transfer = transfer
        self.schedule = schedule
        self.statistics = statistics
        self.customer = customer
        self.id = id
        self.type = type
        self.amount = amount
        self.currency = currency
        self.status = status
        self.companyId = companyId
        self.brandId = brandId
        self.capture = capture
        self.authorization = authorization
        self.archived = archived
        self.description = description
        self.oneOff = oneOff
        self.reference = reference
        self.items = items
        self.transactions = transactions
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.value = value
        self.externalId = externalId
        self.meta = meta
        self.logsMigrated = logsMigrated
        self.tokenId = tokenId
    }
}

/// Transfer information structure
public struct CaptureChargeTransfer: Codable {
    /// Transfer items
    public let items: [String]

    public init(items: [String]) {
        self.items = items
    }
}

/// Schedule information structure
public struct CaptureChargeSchedule: Codable {
    /// Whether schedule is stopped
    public let stopped: Bool

    public init(stopped: Bool) {
        self.stopped = stopped
    }
}

/// Statistics information structure
public struct CaptureChargeStatistics: Codable {
    /// Total refunded amount
    public let totalRefundedAmount: Decimal

    /// Full refund flag
    public let fullRefund: Bool

    /// Need sync flag
    public let needSync: Bool

    public init(totalRefundedAmount: Decimal, fullRefund: Bool, needSync: Bool) {
        self.totalRefundedAmount = totalRefundedAmount
        self.fullRefund = fullRefund
        self.needSync = needSync
    }
}

/// Transaction information structure
public struct CaptureChargeTransaction: Codable {
    /// Creation timestamp
    public let createdAt: String?

    /// Transaction type
    public let type: String

    /// Transaction status
    public let status: String

    /// Transaction amount
    public let amount: Decimal

    /// Currency code
    public let currency: String

    /// Gateway specific code (optional)
    public let gatewaySpecificCode: String?

    /// Gateway specific description (optional)
    public let gatewaySpecificDescription: String?

    /// Error message (optional)
    public let errorMessage: String?

    /// Error code (optional)
    public let errorCode: String?

    /// Status code (optional)
    public let statusCode: String?

    /// Status code description (optional)
    public let statusCodeDescription: String?

    /// Include authorization flag
    public let includeAuthorization: Bool?

    /// First payment flag (optional)
    public let firstPayment: Bool?

    /// Transaction unique identifier
    public let id: String

    /// External identifier (optional)
    public let externalId: String?

    /// System trace audit number (optional)
    public let systemTraceAuditNumber: String?

    /// External reference (optional)
    public let externalReference: String?

    /// Authorization code (optional)
    public let authorizationCode: String?

    /// Network transaction identifier (optional)
    public let networkTransactionId: String?

    /// Remittance date (optional)
    public let remittanceDate: String?

    /// Processed timestamp (optional)
    public let processedAt: String?

    /// Service logs (optional)
    public let serviceLogs: [String]?

    /// Last update timestamp (optional)
    public let updatedAt: String?

    public enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case type
        case status
        case amount
        case currency
        case gatewaySpecificCode = "gateway_specific_code"
        case gatewaySpecificDescription = "gateway_specific_description"
        case errorMessage = "error_message"
        case errorCode = "error_code"
        case statusCode = "status_code"
        case statusCodeDescription = "status_code_description"
        case includeAuthorization = "include_authorization"
        case firstPayment = "first_payment"
        case externalId = "external_id"
        case systemTraceAuditNumber = "system_trace_audit_number"
        case externalReference = "external_reference"
        case authorizationCode = "authorization_code"
        case networkTransactionId = "network_transaction_id"
        case remittanceDate = "remittance_date"
        case processedAt = "processed_at"
        case serviceLogs = "service_logs"
        case updatedAt = "updated_at"
        case id = "_id"
    }

    public init(createdAt: String?,
                type: String,
                status: String,
                amount: Decimal,
                currency: String,
                gatewaySpecificCode: String?,
                gatewaySpecificDescription: String?,
                errorMessage: String?,
                errorCode: String?,
                statusCode: String?,
                statusCodeDescription: String?,
                includeAuthorization: Bool?,
                firstPayment: Bool?,
                id: String,
                externalId: String?,
                systemTraceAuditNumber: String?,
                externalReference: String?,
                authorizationCode: String?,
                networkTransactionId: String?,
                remittanceDate: String?,
                processedAt: String?,
                serviceLogs: [String]?,
                updatedAt: String?) {
        self.createdAt = createdAt
        self.type = type
        self.status = status
        self.amount = amount
        self.currency = currency
        self.gatewaySpecificCode = gatewaySpecificCode
        self.gatewaySpecificDescription = gatewaySpecificDescription
        self.errorMessage = errorMessage
        self.errorCode = errorCode
        self.statusCode = statusCode
        self.statusCodeDescription = statusCodeDescription
        self.includeAuthorization = includeAuthorization
        self.firstPayment = firstPayment
        self.id = id
        self.externalId = externalId
        self.systemTraceAuditNumber = systemTraceAuditNumber
        self.externalReference = externalReference
        self.authorizationCode = authorizationCode
        self.networkTransactionId = networkTransactionId
        self.remittanceDate = remittanceDate
        self.processedAt = processedAt
        self.serviceLogs = serviceLogs
        self.updatedAt = updatedAt
    }
}

/// Metadata information structure
public struct CaptureChargeMeta: Codable {
    /// Store identifier (optional)
    public let storeId: String?

    /// Store name (optional)
    public let storeName: String?

    /// Success URL (optional)
    public let successUrl: String?

    /// Error URL (optional)
    public let errorUrl: String?

    /// Merchant name (optional)
    public let merchantName: String?

    public init(storeId: String?,
                storeName: String?,
                successUrl: String?,
                errorUrl: String?,
                merchantName: String?) {
        self.storeId = storeId
        self.storeName = storeName
        self.successUrl = successUrl
        self.errorUrl = errorUrl
        self.merchantName = merchantName
    }
}
