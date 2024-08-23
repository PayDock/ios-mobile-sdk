//
//  CardsEndpoints.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 12.07.2023..
//

import Foundation
import NetworkingLib

enum CardsEndpoints {

    case cardToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq, accessToken: String)
    case giftCardToken(tokeniseGiftCardReq: TokeniseGiftCardReq, accessToken: String)

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
        case let .cardToken(_, accessToken), let .giftCardToken(_, accessToken):
            return [
                "x-access-token": accessToken,
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .cardToken(let request, _): return try? encoder.encode(request)
        case .giftCardToken(let request, _): return try? encoder.encode(request)
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        default: return []
        }
    }

}
