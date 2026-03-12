//
//  CreateCustomerTokenReq.swift
//  DataCustomer
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.
//

import Foundation
import CommonModels

/// Request model for POST /v1/customers
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#ced5323d-bd0d-48b4-8ea8-e3979f28814e
public struct CreateCustomerTokenReq: Codable {

    /// Payment source token (vault token) to associate with the customer (required)
    public let token: String

    /// Customer's first name (optional)
    public let firstName: String?

    /// Customer's last name (optional)
    public let lastName: String?

    /// Customer's email address (optional)
    public let email: String?

    /// Customer's phone number (optional)
    public let phone: String?

    /// External customer identifier from your system (optional)
    public let externalId: String?

    /// Flag indicating if the customer is marked as suspicious (optional)
    public let suspicious: Bool?

    /// Payment source details (optional)
    public let paymentSource: PaymentSource?

    /// Convenience initializer for backward compatibility
    public init(token: String,
                firstName: String? = nil,
                lastName: String? = nil,
                email: String? = nil,
                phone: String? = nil,
                externalId: String? = nil,
                suspicious: Bool? = nil,
                paymentSource: PaymentSource? = nil) {
        self.token = token
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.externalId = externalId
        self.suspicious = suspicious
        self.paymentSource = paymentSource
    }
}
