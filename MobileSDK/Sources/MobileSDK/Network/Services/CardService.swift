//
//  CardService.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 26.07.2023..
//

import Foundation
import NetworkingLib

protocol CardService {

    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq) async throws -> String
    func createGiftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq) async throws -> String

}

struct CardServiceImpl: HTTPClient, CardService {

    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq) async throws -> String {
        let response = try await sendRequest(endpoint: CardsEndpoints.cardToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq), responseModel: CardTokenRes.self)
        return response.resource.data
    }

    func createGiftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq) async throws -> String {
        let response = try await sendRequest(endpoint: CardsEndpoints.giftCardToken(tokeniseGiftCardReq: tokeniseGiftCardReq), responseModel: CardTokenRes.self)
        return response.resource.data
    }

}
