//
//  WalletCaptureReq.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 09.10.2023..
//

import Foundation

struct WalletCaptureReq: Codable {

    let paymentMethodId: String?
    let customer: WalletCaptureCustomer?

    enum CodingKeys: String, CodingKey {
        case paymentMethodId = "payment_method_id"
        case customer = "customer"
    }
}
