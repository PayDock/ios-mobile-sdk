//
//  WalletEndpoints.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 09.10.2023..
//

import Foundation

enum WalletEndpoints {

    case walletCapture(capture: Bool, token: String, walletCaptureReq: WalletCaptureReq)
    case walletCallback(token: String, walletCallbackReq: WalletCallbackReq)
    case declineWalletTransaction(token: String, chargeId: String)

}

extension WalletEndpoints: Endpoint {

    var path: String {
        switch self {
        case .walletCapture: return "/v1/charges/wallet/capture"
        case .walletCallback: return "/v1/charges/wallet/callback"
        case .declineWalletTransaction(_, let chargeId): return "/v1/charges/wallet/\(chargeId)/decline"
        }
    }

    var method: RequestMethod {
        switch self {
        case .walletCapture: return .post
        case .walletCallback: return .post
        case .declineWalletTransaction: return .post
        }
    }

    var header: [String: String]? {
        switch self {
        case let .walletCapture(_, token, _), .walletCallback(let token, _), .declineWalletTransaction(let token, _):
            return [
                "x-access-token": "\(token)",
                "Content-Type": "application/json"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .walletCapture(_, _, let walletCaptureReq): return try? JSONEncoder().encode(walletCaptureReq)
        case .walletCallback(_, let walletCallbackReq): return try? JSONEncoder().encode(walletCallbackReq)
        case .declineWalletTransaction: return nil
        }
    }


    var parameters: [URLQueryItem] {
        switch self {
        case let .walletCapture(capture, _, _):
            return capture ? [URLQueryItem(name: "capture", value: "true")] : []
        case .walletCallback: return [URLQueryItem(name: "mobile", value: "true")]
        case .declineWalletTransaction: return []
        }
    }

}
