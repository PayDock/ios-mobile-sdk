//
//  PayPalVaultAuthRes.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.10.2024..
//

struct PayPalVaultAuthRes: Codable {
    let status: Int
    let resource: Resource

    struct Resource: Codable {
        let type: String
        let data: CallbackData
    }

    struct CallbackData: Codable {
        let accessToken: String
        let idToken: String
    }
}
