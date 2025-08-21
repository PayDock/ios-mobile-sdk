//
//  Standalone3DSAuthentication.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct Standalone3DSAuthentication: Codable {
    let type: String
    let date: String
    let version: String
    let customer: Standalone3DSCustomer

    enum CodingKeys: String, CodingKey {
        case type, date, version, customer
    }
}
