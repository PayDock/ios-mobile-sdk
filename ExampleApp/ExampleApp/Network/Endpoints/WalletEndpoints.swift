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
    case cardToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq)
    case integrated3ds(request: Integrated3DSReq)
    case standalone3ds(request: Standalone3DSReq)
    case vaultToken(request: TokeniseCardDetailsReq)

}

extension WalletEndpoints: Endpoint {

    var path: String {
        switch self {
        case .initialiseWalletCharge: return "/v1/charges/wallet"
        case .cardToken: return "/v1/payment_sources/tokens"
        case .integrated3ds: return "/v1/charges/3ds"
        case .standalone3ds: return "/v1/charges/standalone-3ds"
        case .vaultToken: return "/v1/vault/payment_sources"
        }
    }

    var method: RequestMethod {
        switch self {
        case .initialiseWalletCharge: return .post
        case .cardToken: return .post
        case .integrated3ds: return .post
        case .standalone3ds: return .post
        case .vaultToken: return .post
        }
    }

    var header: [String: String]? {
        // TODO: - Change this token down the line to be initialized from Example app config
        let secretKey = "2d7fa96060b38a942a5fe97f244580a5322971b5"
        let accessToken = "90ad3038ae37b947dc225cf35c41b1cfe4295cf9"
        switch self {
        case .initialiseWalletCharge, .vaultToken, .standalone3ds:
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
        case .standalone3ds(let request): return try? JSONEncoder().encode(request)
        case .vaultToken(let request): return try? JSONEncoder().encode(request)
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        case .initialiseWalletCharge: return [URLQueryItem(name: "capture", value: "true")]
        case .cardToken, .integrated3ds, .standalone3ds, .vaultToken: return []
        }
    }

}
