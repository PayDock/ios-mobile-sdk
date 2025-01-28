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

    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq, accessToken: String) async throws -> String
    func createGiftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq, accessToken: String) async throws -> String
    func getCardBinSchema(accessToken: String) async throws -> [BinSchemaRes.BinSchema]

}

struct CardServiceImpl: HTTPClient, CardService {

    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: CardsEndpoints.cardToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq, accessToken: accessToken), responseModel: CardTokenRes.self)
        return response.resource.data
    }

    func createGiftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: CardsEndpoints.giftCardToken(tokeniseGiftCardReq: tokeniseGiftCardReq, accessToken: accessToken), responseModel: CardTokenRes.self)
        return response.resource.data
    }
    
    func getCardBinSchema(accessToken: String) async throws -> [BinSchemaRes.BinSchema] {
        let response = try await sendRequest(endpoint: CardsEndpoints.binSchema(accessToken: accessToken), responseModel: BinSchemaRes.self)
        return response.cardSchemas
    }
}

// MARK: - CardServiceMock

struct CardServiceMock: MockHTTPClient, CardService {
    func createToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq, accessToken: String) async throws -> String {
        return ""
    }
    
    func createGiftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq, accessToken: String) async throws -> String {
        return ""
    }
    
    func getCardBinSchema(accessToken: String) async throws -> [BinSchemaRes.BinSchema] {
        let response = try await sendRequest(endpoint: CardsEndpoints.binSchema(accessToken: accessToken), responseModel: BinSchemaRes.self)
        return response.cardSchemas
    }
}
