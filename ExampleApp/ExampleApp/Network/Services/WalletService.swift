//
//  WalletService.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

protocol WalletService {

    func initialiseWalletCharge(initializeWalletChargeReq: InitialiseWalletChargeReq) async throws -> String
    func initialiseFlyPayWalletCharge(initializeWalletChargeReq: InitialiseWalletChargeReq) async throws -> String
    func createCardToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq) async throws -> String
    func createIntegrated3DSToken(request: Integrated3DSReq) async throws -> String?
    func createIntegrated3DSVaultToken(request: Integrated3DSVaultReq) async throws -> Integrated3DSRes
    func createVaultToken(request: TokeniseCardDetailsReq) async throws -> String
    func convertCardTokenToVaultToken(request: ConvertToVaultTokenReq) async throws -> String
    func createStandalone3DSToken(request: Standalone3DSReq) async throws -> String?
    func captureCharge(request: CaptureChargeReq) async throws -> ChargeResponse

}

struct WalletServiceImpl: HTTPClient, WalletService {
    func initialiseWalletCharge(initializeWalletChargeReq: InitialiseWalletChargeReq) async throws -> String {
        let response = try await sendRequest(endpoint: WalletEndpoints.initialiseWalletCharge(initialiseWalletChargeReq: initializeWalletChargeReq), responseModel: InitialiseWalletChargeRes.self)
        return response.resource.data.token
    }

    func initialiseFlyPayWalletCharge(initializeWalletChargeReq: InitialiseWalletChargeReq) async throws -> String {
        let response = try await sendRequest(endpoint: WalletEndpoints.initialiseFlyPayWalletCharge(initialiseWalletChargeReq: initializeWalletChargeReq), responseModel: InitialiseWalletChargeRes.self)
        return response.resource.data.token
    }

    func createCardToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq) async throws -> String {
        let response = try await sendRequest(endpoint: WalletEndpoints.cardToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq), responseModel: CardTokenRes.self)
        return response.resource.data
    }

    func createIntegrated3DSToken(request: Integrated3DSReq) async throws -> String? {
        let response = try await sendRequest(endpoint: WalletEndpoints.integrated3ds(request: request), responseModel: Integrated3DSRes.self)
        return response.resource.data.threeDS.token
    }

    func createIntegrated3DSVaultToken(request: Integrated3DSVaultReq) async throws -> Integrated3DSRes {
        let response = try await sendRequest(endpoint: WalletEndpoints.integrated3dsVault(request: request), responseModel: Integrated3DSRes.self)
        return response
    }

    func createVaultToken(request: TokeniseCardDetailsReq) async throws -> String {
        let response = try await sendRequest(endpoint: WalletEndpoints.vaultToken(request: request), responseModel: VaultTokenRes.self)
        return response.resource.data.token
    }

    func convertCardTokenToVaultToken(request: ConvertToVaultTokenReq) async throws -> String {
        let response = try await sendRequest(endpoint: WalletEndpoints.convertToVaultToken(request: request), responseModel: VaultTokenRes.self)
        return response.resource.data.token
    }

    func createStandalone3DSToken(request: Standalone3DSReq) async throws -> String? {
        let response = try await sendRequest(endpoint: WalletEndpoints.standalone3ds(request: request), responseModel: Integrated3DSRes.self)
        return response.resource.data.threeDS.token
    }

    func captureCharge(request: CaptureChargeReq) async throws -> ChargeResponse {
        let response = try await sendRequest(endpoint: WalletEndpoints.captureCharge(request: request), responseModel: WalletCaptureRes.self)
        return response.resource.data
    }
}
