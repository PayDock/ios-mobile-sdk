//
//  CreateCustomerTokenPaymentSource.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct CreateCustomerTokenPaymentSource: Codable {
    let type: String
    let checkoutHolder: String
    let checkoutEmail: String
    let externalPayerId: String
    let status: String
    let gatewayId: String
    let gatewayName: String
    let gatewayType: String
    let gatewayMode: String
    let createdAt: String
    let updatedAt: String
    let refToken: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case type
        case checkoutHolder
        case checkoutEmail
        case externalPayerId
        case status
        case gatewayId
        case gatewayName
        case gatewayType
        case gatewayMode
        case createdAt
        case updatedAt
        case refToken
        case id = "_id"
    }
}
