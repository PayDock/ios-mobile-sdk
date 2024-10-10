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

}

struct PayPalVaultServiceImpl: HTTPClient, PayPalVaultService {
    
    func createToken(request: PayPalVaultAuthReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.authToken(request: request, accessToken: accessToken), responseModel: PayPalVaultAuthRes.self)
        return response.resource.data.accessToken
    }
    
}

struct PayPalVaultMockServiceImpl: MockHTTPClient, PayPalVaultService {
    
    func createToken(request: PayPalVaultAuthReq, accessToken: String) async throws -> String {
        let response = try await sendRequest(endpoint: PayPalVaultEndpoints.authToken(request: request, accessToken: accessToken), responseModel: PayPalVaultAuthRes.self)
        return response.resource.data.accessToken
    }
    
}
