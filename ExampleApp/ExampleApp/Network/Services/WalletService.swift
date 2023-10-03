//
//  WalletService.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation

import Foundation

protocol WalletService {

    func initialiseWalletCharge(initializeWalletChargeReq: InitialiseWalletChargeReq) async throws -> String

}

struct WalletServiceImpl: HTTPClient, WalletService {

    func initialiseWalletCharge(initializeWalletChargeReq: InitialiseWalletChargeReq) async throws -> String {
        let response = try await sendRequest(endpoint: WalletEndpoints.initialiseWalletCharge(initialiseWalletChargeReq: initializeWalletChargeReq), responseModel: InitialiseWalletChargeRes.self)
        return response.resource.data

    }

}
