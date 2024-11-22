//
//  CardServiceMock.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 31.07.2023..
//

import XCTest
@testable import MobileSDK

class CardServiceMock: Mockable, CardService {
    
    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq, accessToken: String) async throws -> String {
        let cardTokenRes = loadJSON(filename: "card_tokenisation_success_response", type: CardTokenRes.self)
        return cardTokenRes.resource.data
    }
    
    func createGiftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq, accessToken: String) async throws -> String {
        let cardTokenRes = loadJSON(filename: "card_tokenisation_success_response", type: CardTokenRes.self)
        return cardTokenRes.resource.data
    }

}
