//
//  TokeniseCardDetailsReq.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 27.07.2023..
//

import Foundation

struct TokeniseCardDetailsReq: Codable {

    let gatewayId: String?
    let cardName: String
    let cardNumber: String
    let expireMonth: String
    let expireYear: String
    let cardCcv: String

    enum CodingKeys: String, CodingKey {
        case gatewayId = "gateway_id"
        case cardName = "card_name"
        case cardNumber = "card_number"
        case expireMonth = "expire_month"
        case expireYear = "expire_year"
        case cardCcv = "card_ccv"
    }

}
