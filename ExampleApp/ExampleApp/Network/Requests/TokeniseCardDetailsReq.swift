//
//  TokeniseCardDetailsReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

struct TokeniseCardDetailsReq: Codable {

    let gatewayId: String?
    let cardName: String?
    let cardNumber: String
    let expireMonth: String
    let expireYear: String
    let cardCcv: String
    var storeCcv: Bool = true

}
