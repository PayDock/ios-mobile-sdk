//
//  ConvertToVaultTokenReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.01.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation

struct ConvertToVaultTokenReq: Codable {

    let token: String
    let vaultType: String


    enum CodingKeys: String, CodingKey {
        case token
        case vaultType = "vault_type"
    }

}
