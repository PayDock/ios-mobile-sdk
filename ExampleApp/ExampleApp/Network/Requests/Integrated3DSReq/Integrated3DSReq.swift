//
//  Integrated3DSReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 28.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

struct Integrated3DSReq: Codable {

    let amount: String
    let currency: String
    let threeDS: Integrated3DSData
    let token: String

    enum CodingKeys: String, CodingKey {

        case amount = "amount"
        case currency = "currency"
        case threeDS = "_3ds"
        case token = "token"

    }
}
