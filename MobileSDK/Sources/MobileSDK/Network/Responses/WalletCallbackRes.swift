//
//  WalletCallbackRes.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 12.10.2023..
//

import Foundation

struct WalletCallbackRes: Codable {
    let status: Int
    let resource: Resource

    struct Resource: Codable {
        let type: String
        let data: CallbackData
    }

    struct CallbackData: Codable {
        let callbackUrl: String

        enum CodingKeys: String, CodingKey {
            case callbackUrl = "callback_url"
        }
    }
}
