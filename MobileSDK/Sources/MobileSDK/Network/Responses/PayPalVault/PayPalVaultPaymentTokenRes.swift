//
//  PayPalVaultPaymentTokenRes.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 11.10.2024..
//

struct PayPalVaultPaymentTokenRes: Codable {
    let status: Int
    let resource: Resource

    struct Resource: Codable {
        let type: String
        let data: CallbackData
    }

    struct CallbackData: Codable {
        let paymentToken: String
    }
}
