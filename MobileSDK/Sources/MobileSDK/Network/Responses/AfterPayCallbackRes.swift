//
//  AfterPayCallbackRes.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.02.2024..
//

import Foundation

struct AfterPayCallbackRes: Codable {
    let status: Int
    let error: ErrorRes?
    let resource: Resource

    struct Resource: Codable {
        let type: String
        let data: WalletData

        struct WalletData: Codable {
            let refToken: String
            let charge: Charge

            enum CodingKeys: String, CodingKey {
                case refToken = "ref_token"
                case charge
            }

            struct Charge: Codable {
                let status: String
            }
        }
    }
}
