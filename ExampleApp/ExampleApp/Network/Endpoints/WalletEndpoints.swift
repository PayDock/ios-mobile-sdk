//
//  WalletEndpoints.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

enum WalletEndpoints {

    case initialiseWalletCharge(initialiseWalletChargeReq: InitialiseWalletChargeReq)
    // only used for demo purposes - this is usually done in the SDK
    case cardToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq)
    case integrated3ds(request: Integrated3DSReq)

}

extension WalletEndpoints: Endpoint {

    var path: String {
        switch self {
        case .initialiseWalletCharge: return "/v1/charges/wallet"
        case .cardToken: return "/v1/payment_sources/tokens"
        case .integrated3ds: return "/v1/charges/3ds"
        }
    }

    var method: RequestMethod {
        switch self {
        case .initialiseWalletCharge: return .post
        case .cardToken: return .post
        case .integrated3ds: return .post
        }
    }

    var header: [String: String]? {
        // TODO: - Change this token down the line to be initialized from Example app config
        let secretKey = "2d7fa96060b38a942a5fe97f244580a5322971b5"
        let accessToken = "90ad3038ae37b947dc225cf35c41b1cfe4295cf9"
        switch self {
        case .initialiseWalletCharge:
            return [
                "x-user-secret-key": "\(secretKey)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        case .cardToken, .integrated3ds:
            return [
                "x-user-public-key": "\(accessToken)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .initialiseWalletCharge(let request): return try? JSONEncoder().encode(request)
        case .cardToken(let request): return try? JSONEncoder().encode(request)
        case .integrated3ds(let request): return try? JSONEncoder().encode(request)
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        case .initialiseWalletCharge: return [URLQueryItem(name: "capture", value: "true")]
        case .cardToken, .integrated3ds: return []
        }
    }

}
