//
//  VaultMockService.swift
//  DataVault
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Mock service for VaultService that returns fake data for testing
public struct VaultMockService: VaultService {

    public init() {}

    public func createVaultToken(request: ConvertToVaultTokenReq, apiAccessToken: String) async throws -> String {
        return "mock-vault-token-123"
    }

    public func convertCardTokenToVaultToken(request: ConvertToVaultTokenReq, apiAccessToken: String) async throws -> String {
        return "mock-converted-vault-token-456"
    }
}
