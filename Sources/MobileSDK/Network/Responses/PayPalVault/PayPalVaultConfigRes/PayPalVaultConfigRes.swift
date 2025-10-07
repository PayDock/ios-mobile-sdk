//
//  PayPalVaultConfigRes.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 10.10.2024..
//

struct PayPalVaultConfigRes: Codable {
    let status: Int
    let resource: Resource

    struct Resource: Codable {
        let type: String
        let data: PayPalVaultCallbackData
    }
}
