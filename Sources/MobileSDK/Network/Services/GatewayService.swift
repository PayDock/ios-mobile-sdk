//
//  GatewayService.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.

import Foundation
import NetworkingLib

/// Service for all `/v1/gateways/*` endpoints
protocol GatewayService {

    func getClientId(gatewayId: String, accessToken: String) async throws -> String
}

// MARK: - GatewayServiceImpl

struct GatewayServiceImpl: HTTPClient, GatewayService {

    func getClientId(gatewayId: String, accessToken: String) async throws -> String {
        let response = try await sendRequest(
            endpoint: GatewayEndpoints.clientId(gatewayId: gatewayId, accessToken: accessToken),
            responseModel: PayPalVaultConfigRes.self)
        return response.resource.data.credentials.clientAuth
    }
}

// MARK: - GatewayMockServiceImpl

struct GatewayMockServiceImpl: MockHTTPClient, GatewayService {

    func getClientId(gatewayId: String, accessToken: String) async throws -> String {
        let response = try await sendRequest(
            endpoint: GatewayEndpoints.clientId(gatewayId: gatewayId, accessToken: accessToken),
            responseModel: PayPalVaultConfigRes.self)
        return response.resource.data.credentials.clientAuth
    }
}
