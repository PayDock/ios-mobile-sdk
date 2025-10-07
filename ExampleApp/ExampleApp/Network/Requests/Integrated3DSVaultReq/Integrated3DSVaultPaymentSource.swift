//
//  Integrated3DSVaultPaymentSource.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct Integrated3DSVaultPaymentSource: Codable {
    let vaultToken: String
    let gatewayId: String

    enum CodingKeys: String, CodingKey {
        case vaultToken = "vault_token"
        case gatewayId = "gateway_id"
    }
}
