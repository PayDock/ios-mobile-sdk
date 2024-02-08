//
//  Integrated3DSReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 28.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

struct Integrated3DSReq: Codable {

    let amount: String
    let currency: String
    let _3ds: _3DS
    let token: String

    enum CodingKeys: String, CodingKey {

        case amount = "amount"
        case currency = "currency"
        case _3ds = "_3ds"
        case token = "token"

    }

    struct _3DS: Codable {
        let browserDetails: BrowserDetails

        enum CodingKeys: String, CodingKey {
            case browserDetails = "browser_details"
        }

        struct BrowserDetails: Codable {

            let colorDepth = "24"
            let javaEnabled = "true"
            let language = "en-US"
            let name = "chrome"
            let screenHeight = "640"
            let screenWidth = "480"
            let timeZone = "273"

            enum CodingKeys: String, CodingKey {
                case colorDepth = "color_depth"
                case javaEnabled = "java_enabled"
                case language = "language"
                case name = "name"
                case screenHeight = "screen_height"
                case screenWidth = "screen_width"
                case timeZone = "time_zone"

            }
        }
    }

}
