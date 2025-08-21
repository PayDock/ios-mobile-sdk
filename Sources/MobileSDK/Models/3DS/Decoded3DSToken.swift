//
//  Decoded3DSToken.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 28.02.2025..
//  Copyright © 2025 Paydock Ltd.
//

struct Decoded3DSToken: Codable {

    let content: String
    let format: ThreeDsFormat
    let charge3dsId: String?

    enum ThreeDsFormat: String, Codable {
        case html // Used in Integrated3DS token
        case url // Used in Integrated3DS token
        case standalone3ds = "standalone_3ds" // Used in Standalone3DS token
    }

    enum CodingKeys: String, CodingKey {
        case content
        case format
        case charge3dsId = "charge_3ds_id"
    }
}
