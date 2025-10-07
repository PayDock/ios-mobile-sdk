//
//  Integrated3DSVaultReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.01.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation

struct Integrated3DSVaultReq: Codable {

    let amount: String
    let currency: String
    let customer: Integrated3DSVaultCustomer
    let threeDS: Integrated3DSData

    enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case currency = "currency"
        case threeDS = "_3ds"
        case customer = "customer"
    }
}
