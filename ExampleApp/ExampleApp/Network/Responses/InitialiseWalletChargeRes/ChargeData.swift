//
//  ChargeData.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct ChargeData: Codable {
    let id: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
    }
}
