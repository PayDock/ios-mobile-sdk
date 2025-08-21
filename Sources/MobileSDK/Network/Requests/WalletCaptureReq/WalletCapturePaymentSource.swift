//
//  WalletCapturePaymentSource.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd.
//

import Foundation

struct WalletCapturePaymentSource: Codable {
    let externalPayerId: String?
    let refToken: String?

    enum CodingKeys: String, CodingKey {
        case externalPayerId = "external_payer_id"
        case refToken = "ref_token"
    }
}
