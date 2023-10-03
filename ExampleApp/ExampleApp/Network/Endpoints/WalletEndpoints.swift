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

}

extension WalletEndpoints: Endpoint {

    var path: String {
        switch self {
        case .initialiseWalletCharge: return "/v1/charges/wallet"
        }
    }

    var method: RequestMethod {
        switch self {
        case .initialiseWalletCharge: return .post
        }
    }

    var header: [String: String]? {
        // TODO: - Change this token down the line to be initialized from Example app config
        let accessToken = "90ad3038ae37b947dc225cf35c41b1cfe4295cf9"
        switch self {
        case .initialiseWalletCharge:
            return [
                "x-user-public-key": "\(accessToken)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .initialiseWalletCharge(let initialiseWalletChargeReq): return try? JSONEncoder().encode(initialiseWalletChargeReq)
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        case .initialiseWalletCharge: [URLQueryItem(name: "capture", value: "true")]
        }
    }


}
