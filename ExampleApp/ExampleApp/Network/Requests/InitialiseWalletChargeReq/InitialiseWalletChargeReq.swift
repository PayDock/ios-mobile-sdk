//
//  InitialiseWalletChargeReq.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 02.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

struct InitialiseWalletChargeReq: Codable {

    let customer: InitialiseWalletChargeCustomer
    let amount: Decimal
    let currency: String
    let reference: String
    let description: String
    let meta: InitialiseWalletChargeMetaData
}
