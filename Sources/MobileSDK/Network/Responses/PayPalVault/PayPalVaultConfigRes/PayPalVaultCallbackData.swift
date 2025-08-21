//
//  PayPalVaultCallbackData.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

struct PayPalVaultCallbackData: Codable {
    let type: String
    let mode: String
    let credentials: Credentials

    struct Credentials: Codable {
        let clientAuth: String
    }
}
