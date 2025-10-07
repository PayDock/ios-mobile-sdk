//
//  InitialiseWalletChargeRes.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import NetworkingLib

struct InitialiseWalletChargeRes: Codable {
    let status: Int
    let error: ErrorRes?
    let resource: WalletChargeResource
}
