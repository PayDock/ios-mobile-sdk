//
//  InitialiseWalletChargeMetaData.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct InitialiseWalletChargeMetaData: Codable {
    let storeName: String
    let merchantName: String
    let storeId: String
    let successUrl: String?
    let errorUrl: String?

    enum CodingKeys: String, CodingKey {
        case storeName = "store_name"
        case merchantName = "merchant_name"
        case storeId = "store_id"
        case successUrl = "success_url"
        case errorUrl = "error_url"
    }
}
