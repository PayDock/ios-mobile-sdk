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
        let secretKey = "2d7fa96060b38a942a5fe97f244580a5322971b5"
        switch self {
        case .initialiseWalletCharge:
            return [
                "x-user-secret-key": "\(secretKey)",
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
        case .initialiseWalletCharge: return [URLQueryItem(name: "capture", value: "true")]
        }
    }


}
