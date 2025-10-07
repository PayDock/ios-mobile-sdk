//
//  Standalone3DSSource.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct Standalone3DSSource: Codable {
    let created: String
    let attempts: [String]
    let cardType: String

    enum CodingKeys: String, CodingKey {
        case created = "created_at"
        case attempts = "add_attempts"
        case cardType = "card_type"
    }
}
