//
//  Integrated3DSVaultCustomer.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct Integrated3DSVaultCustomer: Codable {
    let paymentSource: Integrated3DSVaultPaymentSource

    enum CodingKeys: String, CodingKey {
        case paymentSource = "payment_source"
    }
}
