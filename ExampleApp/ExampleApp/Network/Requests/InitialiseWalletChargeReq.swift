//
//  InitialiseWalletChargeReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

struct InitialiseWalletChargeReq: Codable {

    let customer: Customer
    let amount: Decimal
    let currency: String
    let reference: String
    let description: String
    let meta: MetaData

    struct Customer: Codable {
        let firstName: String
        let lastName: String
        let email: String
        let phone: String
        let paymentSource: PaymentSource

        enum CodingKeys: String, CodingKey {
            case firstName = "first_name"
            case lastName = "last_name"
            case email, phone
            case paymentSource = "payment_source"
        }

        struct PaymentSource: Codable {
            let gatewayId: String

            enum CodingKeys: String, CodingKey {
                case gatewayId = "gateway_id"
            }
        }
    }

    struct MetaData: Codable {
        let storeName: String
        let storeId: String

        enum CodingKeys: String, CodingKey {
            case storeName = "store_name"
            case storeId = "store_id"
        }
    }
}
