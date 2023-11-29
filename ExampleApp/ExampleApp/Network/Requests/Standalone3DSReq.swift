//
//  Integrated3DSTokenReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

struct Standalone3DSReq: Codable {
    let amount: String
    let currency: String
    let reference: String
    let customer: Customer
    let data: Data

    enum CodingKeys: String, CodingKey {
        case amount, currency, reference, customer
        case data = "_3ds"
    }

    struct Customer: Codable {
        let paymentSource: PaymentSource

        enum CodingKeys: String, CodingKey {
            case paymentSource = "payment_source"
        }

        struct PaymentSource: Codable {
            let token: String

            enum CodingKeys: String, CodingKey {
                case token = "vault_token"
            }
        }
    }

    struct Data: Codable {
        let service_id: String
        let authentication: Authentication

        struct Authentication: Codable {
            let type: String
            let date: String
            let version: String
            let customer: Customer

            enum CodingKeys: String, CodingKey {
                case type, date, version, customer
            }

            struct Customer: Codable {
                let created: String
                let updated: String
                let credsUpdated: String
                let suspicious: Bool
                let source: Source

                enum CodingKeys: String, CodingKey {
                    case created = "created_at"
                    case updated = "updated_at"
                    case credsUpdated = "credentials_updated_at"
                    case suspicious = "suspicious"
                    case source = "payment_source"
                }

                struct Source: Codable {
                    let created: String
                    let attempts: [String]
                    let cardType: String

                    enum CodingKeys: String, CodingKey {
                        case created = "created_at"
                        case attempts = "add_attempts"
                        case cardType = "card_type"
                    }
                }
            }
        }
    }
}
