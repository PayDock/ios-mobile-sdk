//
//  CaptureChargeStandaloneReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 17.10.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

struct CaptureChargeStandaloneReq: Codable {
    let amount: String
    let currency: String
    let customer: Customer
    let description: String
    let reference: String
    let threeDSChargeId: String

    enum CodingKeys: String, CodingKey {
        case amount
        case currency
        case customer
        case description
        case reference
        case threeDSChargeId = "_3ds_charge_id"
    }
}

struct Customer: Codable {
    let email: String
    let firstName: String
    let lastName: String
    let paymentSource: PaymentSource
    let phone: String
    let suspicious: Bool

    enum CodingKeys: String, CodingKey {
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case paymentSource = "payment_source"
        case phone
        case suspicious
    }
}

struct PaymentSource: Codable {
    let gatewayID: String
    let vaultToken: String

    enum CodingKeys: String, CodingKey {
        case gatewayID = "gateway_id"
        case vaultToken = "vault_token"
    }
}
