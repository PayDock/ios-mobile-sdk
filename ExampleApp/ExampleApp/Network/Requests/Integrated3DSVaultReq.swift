//
//  Integrated3DSVaultReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.01.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation

struct Integrated3DSVaultReq: Codable {

    let amount: String
    let currency: String
    let customer: Customer
    let _3ds: _3DS

    enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case currency = "currency"
        case _3ds = "_3ds"
        case customer = "customer"
    }

    struct Customer: Codable {
        let paymentSource: PaymentSource

        enum CodingKeys: String, CodingKey {
            case paymentSource = "payment_source"
        }

        struct PaymentSource: Codable {
            let vaultToken: String
            let gayewayId: String

            enum CodingKeys: String, CodingKey {
                case vaultToken = "vault_token"
                case gayewayId = "gateway_id"
            }
        }
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
