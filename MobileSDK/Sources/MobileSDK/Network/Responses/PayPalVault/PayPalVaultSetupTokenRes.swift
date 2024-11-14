//
//  PayPalVaultSetupTokenRes.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 08.10.2024..
//

import Foundation

struct PayPalVaultSetupTokenRes: Codable {
    let status: Int
    let resource: Resource

    struct Resource: Codable {
        let type: String
        let data: SetupTokenData
    }

    struct SetupTokenData: Codable {
        let setupToken: String
        let approveLink: URL
    }
}
