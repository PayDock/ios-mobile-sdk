//
//  CreateCustomerTokenRes.swift
//  DataCustomer
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import CommonModels

/// Response model for POST /v1/customers
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#ced5323d-bd0d-48b4-8ea8-e3979f28814e
public struct CreateCustomerTokenRes: Codable {

    /// HTTP status code of the response
    public let status: Int

    /// Resource data containing customer information
    public let resource: Customer

    public init(status: Int, resource: Customer) {
        self.status = status
        self.resource = resource
    }
}

///// Resource wrapper for customer token response
///// Part of POST /v1/customers response model
///// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#ced5323d-bd0d-48b4-8ea8-e3979f28814e
// public struct CreateCustomerTokenResource: Codable {
//    /// Resource type identifier
//    public let type: String
//    
//    /// Customer data
//    public let data: CreateCustomerTokenCustomerData
//    
//    public init(type: String, data: CreateCustomerTokenCustomerData) {
//        self.type = type
//        self.data = data
//    }
// }
//
///// Customer data structure from customer creation response
///// Part of POST /v1/customers response model
///// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#ced5323d-bd0d-48b4-8ea8-e3979f28814e
// public struct CreateCustomerTokenCustomerData: Codable {
//    /// Company identifier associated with the customer
//    public let companyId: String
//    
//    /// Customer's first name
//    public let firstName: String
//    
//    /// Customer's last name
//    public let lastName: String
//    
//    /// Customer's email address (optional)
//    public let email: String?
//    
//    /// Customer's phone number
//    public let phone: String
//    
//    /// Flag indicating if expiration date checking is enabled
//    public let checkExpireDate: Bool
//    
//    /// Service configuration for the customer
//    public let service: CreateCustomerTokenService
//    
//    /// Transaction statistics for the customer
//    public let statistics: CreateCustomerTokenStatistics
//    
//    /// Flag indicating if the customer is archived
//    public let archived: Bool
//    
//    /// Customer status
//    public let status: String
//    
//    /// List of payment sources associated with the customer
//    public let paymentSources: [CreateCustomerTokenPaymentSource]
//    
//    /// Default payment source identifier
//    public let defaultSource: String
//    
//    /// Customer unique identifier
//    public let id: String
//    
//    /// List of payment destination identifiers
//    public let paymentDestinations: [String]
//    
//    /// Last update timestamp
//    public let updatedAt: String
//    
//    /// Creation timestamp
//    public let createdAt: String
//    
//    /// Version number
//    public let value: Int
//
//    public enum CodingKeys: String, CodingKey {
//        case companyId
//        case firstName
//        case lastName
//        case email
//        case phone
//        case checkExpireDate = "_checkExpireDate"
//        case service = "_service"
//        case statistics
//        case archived
//        case status
//        case paymentSources
//        case defaultSource
//        case id = "_id"
//        case paymentDestinations
//        case updatedAt
//        case createdAt
//        case value = "__v"
//    }
//    
//    public init(companyId: String,
//                firstName: String,
//                lastName: String,
//                email: String?,
//                phone: String,
//                checkExpireDate: Bool,
//                service: CreateCustomerTokenService,
//                statistics: CreateCustomerTokenStatistics,
//                archived: Bool,
//                status: String,
//                paymentSources: [CreateCustomerTokenPaymentSource],
//                defaultSource: String,
//                id: String,
//                paymentDestinations: [String],
//                updatedAt: String,
//                createdAt: String,
//                value: Int) {
//        self.companyId = companyId
//        self.firstName = firstName
//        self.lastName = lastName
//        self.email = email
//        self.phone = phone
//        self.checkExpireDate = checkExpireDate
//        self.service = service
//        self.statistics = statistics
//        self.archived = archived
//        self.status = status
//        self.paymentSources = paymentSources
//        self.defaultSource = defaultSource
//        self.id = id
//        self.paymentDestinations = paymentDestinations
//        self.updatedAt = updatedAt
//        self.createdAt = createdAt
//        self.value = value
//    }
//
//    /// Service configuration structure
//    public struct CreateCustomerTokenService: Codable {
//        /// Default gateway identifier for the customer
//        public let defaultGatewayId: String
//        
//        public init(defaultGatewayId: String) {
//            self.defaultGatewayId = defaultGatewayId
//        }
//    }
//
//    /// Transaction statistics structure
//    public struct CreateCustomerTokenStatistics: Codable {
//        /// Number of successful transactions
//        public let successfulTransactions: Int
//        
//        /// Total amount collected across all transactions
//        public let totalCollectedAmount: Int
//        
//        public init(successfulTransactions: Int, totalCollectedAmount: Int) {
//            self.successfulTransactions = successfulTransactions
//            self.totalCollectedAmount = totalCollectedAmount
//        }
//    }
// }
//
///// Payment source structure from customer creation response
///// Part of POST /v1/customers response model
///// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#ced5323d-bd0d-48b4-8ea8-e3979f28814e
// public struct CreateCustomerTokenPaymentSource: Codable {
//    /// Payment source type
//    public let type: String
//    
//    /// Checkout holder name
//    public let checkoutHolder: String
//    
//    /// Checkout email address
//    public let checkoutEmail: String
//    
//    /// External payer identifier from payment provider
//    public let externalPayerId: String
//    
//    /// Payment source status
//    public let status: String
//    
//    /// Gateway identifier
//    public let gatewayId: String
//    
//    /// Gateway name
//    public let gatewayName: String
//    
//    /// Gateway type
//    public let gatewayType: String
//    
//    /// Gateway mode
//    public let gatewayMode: String
//    
//    /// Creation timestamp
//    public let createdAt: String
//    
//    /// Last update timestamp
//    public let updatedAt: String
//    
//    /// Reference token from wallet providers
//    public let refToken: String
//    
//    /// Payment source unique identifier
//    public let id: String
//
//    public enum CodingKeys: String, CodingKey {
//        case type
//        case checkoutHolder
//        case checkoutEmail
//        case externalPayerId
//        case status
//        case gatewayId
//        case gatewayName
//        case gatewayType
//        case gatewayMode
//        case createdAt
//        case updatedAt
//        case refToken
//        case id = "_id"
//    }
//    
//    public init(type: String,
//                checkoutHolder: String,
//                checkoutEmail: String,
//                externalPayerId: String,
//                status: String,
//                gatewayId: String,
//                gatewayName: String,
//                gatewayType: String,
//                gatewayMode: String,
//                createdAt: String,
//                updatedAt: String,
//                refToken: String,
//                id: String) {
//        self.type = type
//        self.checkoutHolder = checkoutHolder
//        self.checkoutEmail = checkoutEmail
//        self.externalPayerId = externalPayerId
//        self.status = status
//        self.gatewayId = gatewayId
//        self.gatewayName = gatewayName
//        self.gatewayType = gatewayType
//        self.gatewayMode = gatewayMode
//        self.createdAt = createdAt
//        self.updatedAt = updatedAt
//        self.refToken = refToken
//        self.id = id
//    }
// }
//
