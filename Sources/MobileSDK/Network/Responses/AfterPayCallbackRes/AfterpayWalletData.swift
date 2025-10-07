//
//  AfterpayWalletData.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

struct AfterpayWalletData: Codable {
    let refToken: String
    let charge: Charge

    struct Charge: Codable {
        let status: String
    }
}
