//
//  GatewayService.swift
//  DataGateways
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// Service for all `/v1/gateways/*` endpoints
public protocol GatewayService {
    func getClientId(gatewayId: String, widgetAccessToken: String) async throws -> String
}

// MARK: - GatewayServiceImpl

public struct GatewayServiceImpl: HTTPClient, GatewayService {

    public init() {}

    public func getClientId(gatewayId: String, widgetAccessToken: String) async throws -> String {
        let response = try await sendRequest(
            endpoint: GatewayEndpoints.clientId(gatewayId: gatewayId, widgetAccessToken: widgetAccessToken),
            responseModel: PayPalConfigRes.self,
            timeout: 60,
            maxRetries: 1)
        return response.resource.data.credentials.clientAuth
    }
}
