//
//  MPGS3dsRes.swift
//  DataMPGS3ds
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib
import CommonModels

/// Response model for POST /v1/charges/3ds (Integrated 3D Secure)
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#fdde4af3-24da-458b-b1b7-96cc56132a79
public struct MPGS3dsRes: Codable {
    /// HTTP status code of the response
    public let status: Int

    /// Resource data containing 3DS authentication information
    public let resource: MPGS3dsResource

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

    public init(status: Int, resource: MPGS3dsResource) {
        self.status = status
        self.resource = resource
    }
}

/// Resource wrapper for integrated 3DS response
public struct MPGS3dsResource: Codable {
    /// Resource type identifier
    public let type: String

    /// 3DS response data
    public let data: MPGS3dsResponseData

    public init(type: String, data: MPGS3dsResponseData) {
        self.type = type
        self.data = data
    }
}

/// 3DS response data structure
public struct MPGS3dsResponseData: Codable {
    /// External identifier for the charge (optional)
    public let externalId: String?

    /// Version number
    public let version: Int?

    /// Creation timestamp
    public let createdAt: String?

    /// Last update timestamp
    public let updatedAt: String?

    /// Company identifier
    public let companyId: String?

    /// Charge amount
    public let amount: Decimal

    /// Currency code (e.g., "USD", "AUD", "EUR")
    public let currency: String

    /// Charge unique identifier
    public let id: String

    /// 3D Secure authentication details
    public let threeDS: MPGS3dsAuthDetails

    /// Array of transactions
    public let transactions: [MPGS3dsTransaction]?

    /// One-off payment flag
    public let oneOff: Bool?

    /// Archived flag
    public let archived: Bool?

    /// Customer information (optional)
    public let customer: Customer?

    /// Capture flag
    public let capture: Bool?

    /// Authentication status
    public let status: String

    public enum CodingKeys: String, CodingKey {
        case externalId
        case version = "__v"
        case createdAt
        case updatedAt
        case companyId
        case amount
        case currency
        case id = "_id"
        case threeDS = "_3ds"
        case transactions
        case oneOff
        case archived
        case customer
        case capture
        case status
    }

    public init(externalId: String?,
                version: Int?,
                createdAt: String?,
                updatedAt: String?,
                companyId: String?,
                amount: Decimal,
                currency: String,
                id: String,
                threeDS: MPGS3dsAuthDetails,
                transactions: [MPGS3dsTransaction]?,
                oneOff: Bool?,
                archived: Bool?,
                customer: Customer?,
                capture: Bool?,
                status: String) {
        self.externalId = externalId
        self.version = version
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.companyId = companyId
        self.amount = amount
        self.currency = currency
        self.id = id
        self.threeDS = threeDS
        self.transactions = transactions
        self.oneOff = oneOff
        self.archived = archived
        self.customer = customer
        self.capture = capture
        self.status = status
    }
}

/// 3DS authentication details structure
public struct MPGS3dsAuthDetails: Codable {

    /// 3ds id (optional)
    public let id: String

    /// 3DS authentication token (optional)
    public let token: String?

    public init(id: String, token: String?) {
        self.id = id
        self.token = token
    }
}

/// Transaction structure from integrated 3DS response
public struct MPGS3dsTransaction: Codable {
    /// Transaction type
    public let type: String

    /// Transaction status
    public let status: String

    /// Gateway-specific code (optional)
    public let gatewaySpecificCode: String?

    /// Gateway-specific description (optional)
    public let gatewaySpecificDescription: String?

    /// Error message if transaction failed (optional)
    public let errorMessage: String?

    /// Error code if transaction failed (optional)
    public let errorCode: String?

    /// Status code (optional)
    public let statusCode: String?

    /// Status code description (optional)
    public let statusCodeDescription: String?

    /// Transaction unique identifier
    public let id: String

    /// Transaction currency
    public let currency: String

    /// Transaction amount
    public let amount: Decimal

    /// Fee amount (optional)
    public let amountFee: Decimal?

    /// Surcharge amount (optional)
    public let amountSurcharge: Decimal?

    /// Original amount (optional)
    public let amountOriginal: Decimal?

    /// Creation timestamp
    public let createdAt: String?

    public enum CodingKeys: String, CodingKey {
        case type
        case status
        case gatewaySpecificCode
        case gatewaySpecificDescription
        case errorMessage
        case errorCode
        case statusCode
        case statusCodeDescription
        case id = "_id"
        case currency
        case amount
        case amountFee
        case amountSurcharge
        case amountOriginal
        case createdAt
    }

    public init(type: String,
                status: String,
                gatewaySpecificCode: String?,
                gatewaySpecificDescription: String?,
                errorMessage: String?,
                errorCode: String?,
                statusCode: String?,
                statusCodeDescription: String?,
                id: String,
                currency: String,
                amount: Decimal,
                amountFee: Decimal?,
                amountSurcharge: Decimal?,
                amountOriginal: Decimal?,
                createdAt: String) {
        self.type = type
        self.status = status
        self.gatewaySpecificCode = gatewaySpecificCode
        self.gatewaySpecificDescription = gatewaySpecificDescription
        self.errorMessage = errorMessage
        self.errorCode = errorCode
        self.statusCode = statusCode
        self.statusCodeDescription = statusCodeDescription
        self.id = id
        self.currency = currency
        self.amount = amount
        self.amountFee = amountFee
        self.amountSurcharge = amountSurcharge
        self.amountOriginal = amountOriginal
        self.createdAt = createdAt
    }
}
