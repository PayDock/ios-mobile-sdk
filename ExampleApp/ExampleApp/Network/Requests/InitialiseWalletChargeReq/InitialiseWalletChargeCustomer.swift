//
//  InitialiseWalletChargeCustomer.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct InitialiseWalletChargeCustomer: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let paymentSource: InitialiseWalletChargePaymentSource

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email, phone
        case paymentSource = "payment_source"
    }
}
