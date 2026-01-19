//
//  GatewayMockService.swift
//  DataGateways
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

/// Mock service for GatewayService that returns fake data for testing
public class GatewayMockService: GatewayService {

    // MARK: - Test Configuration

    public var shouldReturnError = false
    public var errorToReturn: ErrorRes?

    // MARK: - Configurable Results

    public var clientIdResult: String?

    public init() {}

    public func getClientId(gatewayId: String, widgetAccessToken: String) async throws -> String {
        if shouldReturnError, let error = errorToReturn {
            throw RequestError.requestError(error)
        }
        return clientIdResult ?? "mock-paypal-client-id-123"
    }
}
