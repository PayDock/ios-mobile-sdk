//
//  Standalone3DSCustomer.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct Standalone3DSCustomer: Codable {
    let created: String
    let updated: String
    let credsUpdated: String
    let suspicious: Bool
    let source: Standalone3DSSource

    enum CodingKeys: String, CodingKey {
        case created = "created_at"
        case updated = "updated_at"
        case credsUpdated = "credentials_updated_at"
        case suspicious = "suspicious"
        case source = "payment_source"
    }
}
