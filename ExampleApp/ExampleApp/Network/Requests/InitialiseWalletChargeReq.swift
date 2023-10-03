//
//  InitialiseWalletChargeReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

struct InitialiseWalletChargeReq: Codable {

    // TODO: - Optional fields should be added as needed

    let amount: Double
    let currency: String
    let customer: Customer

    struct Customer: Codable {
        let paymentSource: PaymentSource

        struct PaymentSource: Codable {
            let gatewayId: String
        }
    }

}
