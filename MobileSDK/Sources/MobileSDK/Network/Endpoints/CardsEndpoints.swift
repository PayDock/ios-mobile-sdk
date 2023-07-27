//
//  CardsEndpoints.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 12.07.2023..
//

import Foundation

enum CardsEndpoints {

    case example(id: Int)
    case cardToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq)

}

extension CardsEndpoints: Endpoint {

    var path: String {
        switch self {
        case .example(let id): return "/something/example/\(id)"
        case .cardToken: return "/v1/payment_sources/tokens"
        }
    }

    var method: RequestMethod {
        switch self {
        case .example: return .get
        case .cardToken: return .post
        }
    }

    var header: [String: String]? {
        // TODO: - Change this token down the line to be initialized from SDK configuration
        let accessToken = "90ad3038ae37b947dc225cf35c41b1cfe4295cf9"
        switch self {
        case .example, .cardToken:
            return [
                "x-user-public-key": "\(accessToken)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .example: return nil
        case .cardToken(let tokeniseCardDetailsReq): return try? JSONEncoder().encode(tokeniseCardDetailsReq)
        }
    }
    
}
