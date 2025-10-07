//
//  CreateCustomerTokenCustomerData.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct CreateCustomerTokenCustomerData: Codable {
    let companyId: String
    let firstName: String
    let lastName: String
    let email: String?
    let phone: String
    let checkExpireDate: Bool
    let service: Service
    let statistics: Statistics
    let archived: Bool
    let status: String
    let paymentSources: [CreateCustomerTokenPaymentSource]
    let defaultSource: String
    let sourceIpAddress: String
    let id: String
    let paymentDestinations: [String]
    let updatedAt: String
    let createdAt: String
    let value: Int

    enum CodingKeys: String, CodingKey {
        case companyId
        case firstName
        case lastName
        case email
        case phone
        case checkExpireDate = "_checkExpireDate"
        case service = "_service"
        case statistics
        case archived
        case status
        case paymentSources
        case defaultSource
        case sourceIpAddress = "_sourceIpAddress"
        case id = "_id"
        case paymentDestinations
        case updatedAt
        case createdAt
        case value = "__v"
    }

    struct Service: Codable {
        let defaultGatewayId: String
    }

    struct Statistics: Codable {
        let successfulTransactions: Int
        let totalCollectedAmount: Int

    }
}
