//
//  PayPalVaultConfigRes.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 10.10.2024..
//

struct PayPalVaultConfigRes: Codable {
    let status: Int
    let resource: Resource

    struct Resource: Codable {
        let type: String
        let data: CallbackData
    }

    struct CallbackData: Codable {
        let type: String
        let mode: String
        let credentials: Credentials
        
        struct Credentials: Codable {
            let clientAuth: String
        }
    }
}
