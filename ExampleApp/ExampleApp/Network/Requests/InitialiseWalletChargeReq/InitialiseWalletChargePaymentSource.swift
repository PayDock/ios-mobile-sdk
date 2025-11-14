//
//  InitialiseWalletChargePaymentSource.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 20.08.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import Foundation

struct InitialiseWalletChargePaymentSource: Codable {
    let addressLine1: String?
    let addressLine2: String?
    let addressPostcode: String?
    let addressCity: String?
    let addressState: String?
    let addressCountry: String?
    let gatewayId: String
    let walletType: String?
}
