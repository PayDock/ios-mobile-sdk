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

    var authStatus: AuthStatus? {
        return AuthStatus(rawValue: resource.data.status )
    }

    struct Resource: Codable {
        let type: String
        let data: Data3DS
    }

    enum CodingKeys: String, CodingKey {
        case status
        case resource
    }

    enum AuthStatus: String, Codable {
        case notSupported = "authentication_not_supported"
        case pending = "pre_authentication_pending"
    }

    struct Data3DS: Codable {
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
}
