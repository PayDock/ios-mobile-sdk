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

    func createToken(request: PayPalVaultAuthReq, accessToken: String) async throws -> String
    func createSetupTokenData(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> PayPalVaultSetupTokenRes.SetupTokenData
    func getClientId(gatewayId: String, accessToken: String) async throws -> String
    func createPaymentToken(request: PayPalVaultPaymentTokenReq, setupToken: String, accessToken: String) async throws -> PayPalVaultPaymentTokenRes.PaymentTokenData

}

// MARK: - PayPalVaultServiceImpl

struct PayPalVaultServiceImpl: HTTPClient, PayPalVaultService {

    func createToken(request: PayPalVaultAuthReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.authToken(request: request, accessToken: accessToken), responseModel: PayPalVaultAuthRes.self)
        return response.resource.data.accessToken
    }
    
    func createSetupTokenData(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> PayPalVaultSetupTokenRes.SetupTokenData {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.setupToken(request: req, accessToken: accessToken), responseModel: PayPalVaultSetupTokenRes.self)
        return response.resource.data
    }
    
    func getClientId(gatewayId: String, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.clientId(gatewayId: gatewayId, accessToken: accessToken), responseModel: PayPalVaultConfigRes.self)
        return response.resource.data.credentials.clientAuth
    }
    
    func createPaymentToken(request: PayPalVaultPaymentTokenReq, setupToken: String, accessToken: String) async throws -> PayPalVaultPaymentTokenRes.PaymentTokenData {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.paymentToken(setupToken: setupToken, request: request, accessToken: accessToken), responseModel: PayPalVaultPaymentTokenRes.self)
        return response.resource.data
    }
    
}

// MARK: - PayPalVaultMockServiceImpl

struct PayPalVaultMockServiceImpl: MockHTTPClient, PayPalVaultService {
    
    func createToken(request: PayPalVaultAuthReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.authToken(request: request, accessToken: accessToken), responseModel: PayPalVaultAuthRes.self)
        return response.resource.data.accessToken
    }
    
    func createSetupTokenData(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> PayPalVaultSetupTokenRes.SetupTokenData {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.setupToken(request: req, accessToken: accessToken), responseModel: PayPalVaultSetupTokenRes.self)
        return response.resource.data
    }
    
    func getClientId(gatewayId: String, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.clientId(gatewayId: gatewayId, accessToken: accessToken), responseModel: PayPalVaultConfigRes.self)
        return response.resource.data.credentials.clientAuth
    }
    
    func createPaymentToken(request: PayPalVaultPaymentTokenReq, setupToken: String, accessToken: String) async throws -> PayPalVaultPaymentTokenRes.PaymentTokenData {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.paymentToken(setupToken: setupToken, request: request, accessToken: accessToken), responseModel: PayPalVaultPaymentTokenRes.self)
        return response.resource.data
    }
    
}
