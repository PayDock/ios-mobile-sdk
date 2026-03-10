//
//  VaultService.swift
//  DataVault
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

public protocol VaultService {
    func createVaultToken(request: ConvertToVaultTokenReq, apiAccessToken: String) async throws -> String
    func convertCardTokenToVaultToken(request: ConvertToVaultTokenReq, apiAccessToken: String) async throws -> String
}

public struct VaultServiceImpl: HTTPClient, VaultService {

    public init() {}

    public func createVaultToken(request: ConvertToVaultTokenReq, apiAccessToken: String) async throws -> String {
        let endpoint = VaultEndpoints.vaultToken(request: request, apiAccessToken: apiAccessToken)
        let response = try await sendRequest(
            endpoint: endpoint,
            responseModel: VaultTokenRes.self,
            timeout: 60)
        return response.resource.data.vaultToken
    }

    public func convertCardTokenToVaultToken(request: ConvertToVaultTokenReq, apiAccessToken: String) async throws -> String {
        let endpoint = VaultEndpoints.convertToVaultToken(request: request, apiAccessToken: apiAccessToken)
        let response = try await sendRequest(
            endpoint: endpoint,
            responseModel: VaultTokenRes.self,
            timeout: 60)
        return response.resource.data.vaultToken
    }
}
