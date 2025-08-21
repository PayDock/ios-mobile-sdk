//
//  Integrated3DSResponseData.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct Integrated3DSResponseData: Codable {
    let threeDS: ThreeDS
    let status: String

    enum CodingKeys: String, CodingKey {
        case threeDS = "_3ds"
        case status
    }

    struct ThreeDS: Codable {
        let token: String?
        let id: String?
    }
}
