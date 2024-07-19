//
//  WalletEndpoints.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 03.10.2023..
//  Copyright © 2023 Paydock Ltd. All rights reserved.
//

import Foundation
import NetworkingLib

enum WalletEndpoints {

    case initialiseWalletCharge(initialiseWalletChargeReq: InitialiseWalletChargeReq)
    case initialiseFlyPayWalletCharge(initialiseWalletChargeReq: InitialiseWalletChargeReq)
    case cardToken(tokeniseCardDetailsReq: TokeniseCardDetailsReq)
    case integrated3ds(request: Integrated3DSReq)
    case integrated3dsVault(request: Integrated3DSVaultReq)
    case standalone3ds(request: Standalone3DSReq)
    case vaultToken(request: TokeniseCardDetailsReq)
    case convertToVaultToken(request: ConvertToVaultTokenReq)
    case captureCharge(request: CaptureChargeReq)

}

extension WalletEndpoints: Endpoint {

    var path: String {
        switch self {
        case .initialiseWalletCharge, .initialiseFlyPayWalletCharge: return "/v1/charges/wallet"
        case .cardToken: return "/v1/payment_sources/tokens"
        case .integrated3ds, .integrated3dsVault: return "/v1/charges/3ds"
        case .standalone3ds: return "/v1/charges/standalone-3ds"
        case .vaultToken, .convertToVaultToken: return "/v1/vault/payment_sources"
        case .captureCharge: return "/v1/charges"
        }
    }

    var method: RequestMethod {
        switch self {
        case .initialiseWalletCharge: return .post
        case .initialiseFlyPayWalletCharge: return .post
        case .cardToken: return .post
        case .integrated3ds: return .post
        case .integrated3dsVault: return .post
        case .standalone3ds: return .post
        case .vaultToken: return .post
        case .convertToVaultToken: return .post
        case .captureCharge: return .post
        }
    }

    var header: [String: String]? {
        let secretKey = ProjectEnvironment.shared.getSecretKey()
        let publicKey =  ProjectEnvironment.shared.getPublicKey()
        switch self {
        case .initialiseWalletCharge, .initialiseFlyPayWalletCharge, .vaultToken, .convertToVaultToken, .standalone3ds, .captureCharge:
            return [
                "x-user-secret-key": "\(secretKey)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        case .cardToken, .integrated3ds, .integrated3dsVault:
            return [
                "x-user-public-key": "\(publicKey)",
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }

    var body: Data? {
        switch self {
        case .initialiseWalletCharge(let request): return try? JSONEncoder().encode(request)
        case .initialiseFlyPayWalletCharge(let request): return try? JSONEncoder().encode(request)
        case .cardToken(let request): return try? JSONEncoder().encode(request)
        case .integrated3ds(let request): return try? JSONEncoder().encode(request)
        case .integrated3dsVault(let request): return try? JSONEncoder().encode(request)
        case .standalone3ds(let request): return try? JSONEncoder().encode(request)
        case .vaultToken(let request): return try? JSONEncoder().encode(request)
        case .convertToVaultToken(let request): return try? JSONEncoder().encode(request)
        case .captureCharge(let request): return try? JSONEncoder().encode(request)
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        case .initialiseWalletCharge: return [URLQueryItem(name: "capture", value: "true")]
        case .initialiseFlyPayWalletCharge: return [URLQueryItem(name: "capture", value: "false")]
        case .cardToken, .integrated3ds, .standalone3ds, .vaultToken, .convertToVaultToken, .integrated3dsVault, .captureCharge: return []
        }
    }

}
