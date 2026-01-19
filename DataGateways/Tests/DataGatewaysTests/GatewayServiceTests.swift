//
//  GatewayServiceTests.swift
//  DataGatewaysTests
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import XCTest
@testable import DataGateways

final class GatewayServiceTests: XCTestCase {

    func testGatewayMockService() async throws {
        let mockService = GatewayMockService()

        let clientId = try await mockService.getClientId(
            gatewayId: "gateway-123",
            widgetAccessToken: "widget-token-123"
        )

        XCTAssertEqual(clientId, "mock-paypal-client-id-123")
    }
}
