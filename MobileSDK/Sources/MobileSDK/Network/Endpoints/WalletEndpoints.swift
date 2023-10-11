//
//  WalletEndpoints.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 09.10.2023..
//

import Foundation

enum WalletEndpoints {

    case walletCapture(token: String, walletCaptureReq: WalletCaptureReq)

}

extension WalletEndpoints: Endpoint {

    var path: String {
        switch self {
        case .walletCapture: return "/v1/charges/wallet/capture"
        }
    }

    var method: RequestMethod {
        switch self {
        case .walletCapture: return .post
        }
    }

    var header: [String: String]? {
        switch self {
        case .walletCapture(let token, _):
            return [
                "x-access-token": "\(token)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .walletCapture(_, let walletCaptureReq): return try? JSONEncoder().encode(walletCaptureReq)
        }
    }

}
