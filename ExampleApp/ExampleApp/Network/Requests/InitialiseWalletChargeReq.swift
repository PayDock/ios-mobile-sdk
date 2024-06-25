//
//  InitialiseWalletChargeReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

struct InitialiseWalletChargeReq: Codable {

    let customer: Customer
    let amount: Decimal
    let currency: String
    let reference: String
    let description: String
    let meta: MetaData

    struct Customer: Codable {
        let firstName: String
        let lastName: String
        let email: String
        let phone: String
        let paymentSource: PaymentSource

        enum CodingKeys: String, CodingKey {
            case firstName = "first_name"
            case lastName = "last_name"
            case email, phone
            case paymentSource = "payment_source"
        }

        struct PaymentSource: Codable {
            let addressLine1: String?
            let addressPostcode: String?
            let gatewayId: String
            let walletType: String?

            enum CodingKeys: String, CodingKey {
                case addressLine1 = "address_line1"
                case addressPostcode = "address_postcode"
                case gatewayId = "gateway_id"
                case walletType = "wallet_type"
            }
        }
    }

    struct MetaData: Codable {
        let storeName: String
        let merchantName: String
        let storeId: String
        let successUrl: String?
        let errorUrl: String?

        enum CodingKeys: String, CodingKey {
            case storeName = "store_name"
            case merchantName = "merchant_name"
            case storeId = "store_id"
            case successUrl = "success_url"
            case errorUrl = "error_url"
        }
    }
}
