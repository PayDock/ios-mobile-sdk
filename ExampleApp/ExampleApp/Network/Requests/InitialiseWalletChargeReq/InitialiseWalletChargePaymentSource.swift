//
//  InitialiseWalletChargePaymentSource.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct InitialiseWalletChargePaymentSource: Codable {
    let addressLine1: String?
    let addressPostcode: String?
    let gatewayId: String
    let walletType: String?

    enum CodingKeys: String, CodingKey {
        case addressLine1 = "address_line1"
        case addressPostcode = "address_postcode"
        case gatewayId = "gateway_id"
        case walletType = "wallet_type"
    }
}
