//
//  CreateCustomerTokenResource.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct CreateCustomerTokenResource: Codable {
    let type: String
    let data: CreateCustomerTokenCustomerData
}
