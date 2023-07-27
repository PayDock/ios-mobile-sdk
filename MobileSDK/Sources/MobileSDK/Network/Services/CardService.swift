//
//  CardService.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.07.2023..
//

import Foundation

protocol CardService {

    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq) async throws -> CardTokenRes

}

struct CardServiceImpl: HTTPClient, CardService {

    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq) async throws -> CardTokenRes {
        
        return try await sendRequest(endpoint: CardsEndpoints.cardToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq), responseModel: CardTokenRes.self)
    }

}
