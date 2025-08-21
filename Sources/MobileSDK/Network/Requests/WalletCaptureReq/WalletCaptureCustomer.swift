//
//  WalletCaptureCustomer.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd.
//

struct WalletCaptureCustomer: Codable {
    let paymentSource: WalletCapturePaymentSource?

    enum CodingKeys: String, CodingKey {
        case paymentSource = "payment_source"
    }
}
