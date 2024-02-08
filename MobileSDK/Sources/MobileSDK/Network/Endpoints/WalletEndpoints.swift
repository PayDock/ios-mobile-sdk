//
//  WalletEndpoints.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 09.10.2023..
//

import Foundation

enum WalletEndpoints {

    case walletCapture(token: String, walletCaptureReq: WalletCaptureReq)
    case walletCallback(token: String, walletCallbackReq: WalletCallbackReq)

}

extension WalletEndpoints: Endpoint {

    var path: String {
        switch self {
        case .walletCapture: return "/v1/charges/wallet/capture"
        case .walletCallback: return "/v1/charges/wallet/callback"
        }
    }

    var method: RequestMethod {
        switch self {
        case .walletCapture: return .post
        case .walletCallback: return .post
        }
    }

    var header: [String: String]? {
        switch self {
        case .walletCapture(let token, _), .walletCallback(let token, _):
            return [
                "x-access-token": "\(token)",
                "Content-Type": "application/json"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .walletCapture(_, let walletCaptureReq): return try? JSONEncoder().encode(walletCaptureReq)
        case .walletCallback(_, let walletCallbackReq): return try? JSONEncoder().encode(walletCallbackReq)
        }
    }

}
