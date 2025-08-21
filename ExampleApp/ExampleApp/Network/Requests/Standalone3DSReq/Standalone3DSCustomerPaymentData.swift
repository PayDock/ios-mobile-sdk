//
//  Standalone3DSCustomerPaymentData.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct Standalone3DSCustomerPaymentData: Codable {
    let paymentSource: Standalone3DSPaymentSource

    enum CodingKeys: String, CodingKey {
        case paymentSource = "payment_source"
    }
}
