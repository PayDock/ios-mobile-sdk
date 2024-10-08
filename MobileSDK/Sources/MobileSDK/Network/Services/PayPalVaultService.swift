//
//  PayPalVaultService.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 04.10.2024..
//

import Foundation
import NetworkingLib

protocol PayPalVaultService {

    func createToken(gatewayId: String, accessToken: String) async throws -> String
    func createSetupToken(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> String

}

struct PayPalVaultServiceImpl: HTTPClient, PayPalVaultService {
    
    func createToken(gatewayId: String, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.authToken(gatewayId: gatewayId, accessToken: accessToken), responseModel: PayPalVaultAuthRes.self)
        return response.resource.data.accessToken
    }
    
    func createSetupToken(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.setupToken(request: req, accessToken: accessToken), responseModel: PayPalVaultSetupTokenRes.self)
        return response.resource.data.setupToken
    }
    
}

struct PayPalVaultMockServiceImpl: MockHTTPClient, PayPalVaultService {
    
    func createToken(gatewayId: String, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.authToken(gatewayId: gatewayId, accessToken: accessToken), responseModel: PayPalVaultAuthRes.self)
        return response.resource.data.accessToken
    }
    
    func createSetupToken(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.setupToken(request: req, accessToken: accessToken), responseModel: PayPalVaultSetupTokenRes.self)
        return response.resource.data.setupToken
    }
    
}
