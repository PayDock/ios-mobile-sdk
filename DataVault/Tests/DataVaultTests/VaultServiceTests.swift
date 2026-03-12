//
//  VaultServiceTests.swift
//  DataVaultTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import DataVault

final class VaultServiceTests: XCTestCase {

    func testVaultMockServiceCreateVaultToken() async throws {
        let mockService = VaultMockService()

        let request = ConvertToVaultTokenReq(
            token: "payment-token-123",
            vaultType: "permanent",
            gatewayId: "gateway-123"
        )

        let vaultToken = try await mockService.createVaultToken(
            request: request,
            apiAccessToken: "test-token"
        )

        XCTAssertEqual(vaultToken, "mock-vault-token-123")
    }

    func testVaultMockServiceConvertCardToken() async throws {
        let mockService = VaultMockService()

        let request = ConvertToVaultTokenReq(
            token: "card-token-456",
            vaultType: "session"
        )

        let vaultToken = try await mockService.convertCardTokenToVaultToken(
            request: request,
            apiAccessToken: "test-token"
        )

        XCTAssertEqual(vaultToken, "mock-converted-vault-token-456")
    }
}
