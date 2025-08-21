//
//  CreateCustomerTokenRes.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation

struct CreateCustomerTokenRes: Codable {

    let status: Int
    let error: String?
    let resource: CreateCustomerTokenResource
}
