//
//  CardService.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 26.07.2023..
//

import Foundation

protocol CardService {

    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq) async throws -> String

}

struct CardServiceImpl: HTTPClient, CardService {

    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq) async throws -> String {
        let response = try await sendRequest(endpoint: CardsEndpoints.cardToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq), responseModel: CardTokenRes.self)
        return response.resource.data
    }

}
