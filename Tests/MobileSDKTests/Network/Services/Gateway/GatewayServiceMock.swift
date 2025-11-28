//
//  GatewayServiceMock.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import XCTest
@testable import MobileSDK
@testable import NetworkingLib

class GatewayServiceMock: Mockable, GatewayService {

    // Properties for error simulation
    var shouldReturnError = false
    var errorToReturn: ErrorRes?
    var clientId = "test_client_id"

    func getClientId(gatewayId: String, accessToken: String) async throws -> String {
        if shouldReturnError, let errorRes = errorToReturn {
            throw RequestError.requestError(errorRes)
        }
        return clientId
    }
}
