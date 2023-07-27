//
//  TokeniseCardDetailsReq.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 27.07.2023..
//

import Foundation

struct TokeniseCardDetailsReq: Codable {

    let gatewayId: String
    let cardName: String
    let cardNumber: String
    let expireMonth: String
    let expireYear: String
    let cardCcv: String

}
