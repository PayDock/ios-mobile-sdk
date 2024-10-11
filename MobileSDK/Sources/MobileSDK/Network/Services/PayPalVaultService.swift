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
    func createSetupToken(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> String
    func getClientId(gatewayId: String, accessToken: String) async throws -> String
    func createPaymentToken(request: PayPalVaultPaymentTokenReq, accessToken: String) async throws -> String

}

// MARK: - PayPalVaultServiceImpl

struct PayPalVaultServiceImpl: HTTPClient, PayPalVaultService {

    func createToken(request: PayPalVaultAuthReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.authToken(request: request, accessToken: accessToken), responseModel: PayPalVaultAuthRes.self)
        return response.resource.data.accessToken
    }
    
    func createSetupToken(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.setupToken(request: req, accessToken: accessToken), responseModel: PayPalVaultSetupTokenRes.self)
        return response.resource.data.setupToken
    }
    
    func getClientId(gatewayId: String, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.clientId(gatewayId: gatewayId, accessToken: accessToken), responseModel: PayPalVaultConfigRes.self)
        return response.resource.data.credentials.clientAuth
    }
    
    func createPaymentToken(request: PayPalVaultPaymentTokenReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.paymentToken(request: request, accessToken: accessToken), responseModel: PayPalVaultPaymentTokenRes.self)
        return response.resource.data.paymentToken
    }
    
}

// MARK: - PayPalVaultMockServiceImpl

struct PayPalVaultMockServiceImpl: MockHTTPClient, PayPalVaultService {
    
    func createToken(request: PayPalVaultAuthReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.authToken(request: request, accessToken: accessToken), responseModel: PayPalVaultAuthRes.self)
        return response.resource.data.accessToken
    }
    
    func createSetupToken(req: PayPalVaultSetupTokenReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.setupToken(request: req, accessToken: accessToken), responseModel: PayPalVaultSetupTokenRes.self)
        return response.resource.data.setupToken
    }
    
    func getClientId(gatewayId: String, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.clientId(gatewayId: gatewayId, accessToken: accessToken), responseModel: PayPalVaultConfigRes.self)
        return response.resource.data.credentials.clientAuth
    }
    
    func createPaymentToken(request: PayPalVaultPaymentTokenReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.paymentToken(request: request, accessToken: accessToken), responseModel: PayPalVaultPaymentTokenRes.self)
        return response.resource.data.paymentToken
    }
    
}
