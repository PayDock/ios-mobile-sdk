//
//  Standalone3DSPaymentSource.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct Standalone3DSPaymentSource: Codable {
    let token: String

    enum CodingKeys: String, CodingKey {
        case token = "vault_token"
    }
}
