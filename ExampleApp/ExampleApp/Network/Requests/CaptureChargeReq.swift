//
//  CaptureChargeReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.01.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation

struct CaptureChargeReq: Codable {
    let amount: String
    let currency: String
    let customer: Customer

    struct Customer: Codable {
        let paymentSource: PaymentSource

        enum CodingKeys: String, CodingKey {
            case paymentSource = "payment_source"
        }

        struct PaymentSource: Codable {
            let vaultToken: String

            enum CodingKeys: String, CodingKey {
                case vaultToken = "vault_token"
            }
        }
    }
}
