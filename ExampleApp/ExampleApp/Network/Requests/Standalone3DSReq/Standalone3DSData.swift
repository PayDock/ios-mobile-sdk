//
//  Standalone3DSData.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct Standalone3DSData: Codable {
    let serviceId: String
    let authentication: Standalone3DSAuthentication

    enum CodingKeys: String, CodingKey {
        case serviceId = "service_id"
        case authentication
    }
}
