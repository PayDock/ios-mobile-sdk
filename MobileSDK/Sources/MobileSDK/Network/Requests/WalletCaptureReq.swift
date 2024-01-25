//
//  WalletCaptureReq.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 09.10.2023..
//

import Foundation

struct WalletCaptureReq: Codable {

    let paymentMethodId: String?
    let customer: Customer?

    enum CodingKeys: String, CodingKey {
        case paymentMethodId = "payment_method_id"
        case customer = "customer"
    }

    struct Customer: Codable {
        let paymentSource: PaymentSource?

        enum CodingKeys: String, CodingKey {
            case paymentSource = "payment_source"
        }

        struct PaymentSource: Codable {
            let externalPayerId: String?
            let refToken: String?

            enum CodingKeys: String, CodingKey {
                case externalPayerId = "external_payer_id"
                case refToken = "ref_token"
            }
        }
    }

}
