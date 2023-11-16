//
//  TokeniseGiftCardReq.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 16.11.2023..
//

import Foundation

struct TokeniseGiftCardReq: Codable {

    let cardNumber: String
    let pin: String
    let type = "gift_card"
    let scheme = "vii_giftcard"
    let processingNetwork = "vii_giftcard"

    enum CodingKeys: String, CodingKey {
        case cardNumber = "card_number"
        case pin = "card_pin"
        case type = "type"
        case scheme = "card_scheme"
        case processingNetwork = "card_processing_network"
    }
}
