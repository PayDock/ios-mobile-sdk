//
//  Integrated3DSTokenReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

struct Standalone3DSReq: Codable {
    let amount: String
    let currency: String
    let reference: String
    let customer: Standalone3DSCustomerPaymentData
    let data: Standalone3DSData

    enum CodingKeys: String, CodingKey {
        case amount, currency, reference, customer
        case data = "_3ds"
    }
}
