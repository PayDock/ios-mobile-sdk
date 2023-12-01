//
//  Integrated3DSRes.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 28.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

struct Integrated3DSRes: Codable {
    let status: Int
    let resource: Resource

    struct Resource: Codable {
        let type: String
        let data: Data3DS
    }

    struct Data3DS: Codable {
        let threeDS: ThreeDS

        enum CodingKeys: String, CodingKey {
            case threeDS = "_3ds"
        }

        struct ThreeDS: Codable {
            let token: String
        }
    }
}
