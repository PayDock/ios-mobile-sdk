//
//  CardsEndpoints.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 12.07.2023..
//

import Foundation

enum CardsEndpoints {

    case cardToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq)
    case giftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq)

}

extension CardsEndpoints: Endpoint {

    var path: String {
        switch self {
        case .cardToken, .giftCardToken: return "/v1/payment_sources/tokens"
        }
    }

    var method: RequestMethod {
        switch self {
        case .cardToken: return .post
        case .giftCardToken: return .post
        }
    }

    var header: [String: String]? {
        switch self {
        case .cardToken, .giftCardToken:
            return [
                "x-user-public-key": "\(Constants.publicKey)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .cardToken(let tokeniseCardDetailsReq): return try? JSONEncoder().encode(tokeniseCardDetailsReq)
        case .giftCardToken(let tokeniseGiftCardReq): return try? JSONEncoder().encode(tokeniseGiftCardReq)
        }
    }
    
}
