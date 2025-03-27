//
//  WalletCallbackReq.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 12.10.2023..
//

import Foundation

struct WalletCallbackReq: Codable {
    let type: String
    let shipping: Bool?
    let sessionId: String?
    let walletType: String?

    enum CodingKeys: String, CodingKey {
        case type = "request_type"
        case shipping = "request_shipping"
        case sessionId = "session_id"
        case walletType = "wallet_type"
    }
}
