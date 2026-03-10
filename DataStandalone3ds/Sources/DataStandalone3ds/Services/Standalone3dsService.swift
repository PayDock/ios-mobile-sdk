//
//  Standalone3dsService.swift
//  DataStandalone3ds
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

public protocol Standalone3dsService {
    func createStandalone3DSToken(request: Standalone3DSReq, apiAccessToken: String) async throws -> String?
}

public struct Standalone3dsServiceImpl: HTTPClient, Standalone3dsService {

    public init() {}

    public func createStandalone3DSToken(request: Standalone3DSReq, apiAccessToken: String) async throws -> String? {
        let endpoint = Standalone3dsEndpoints.standalone3ds(request: request, apiAccessToken: apiAccessToken)
        let response = try await sendRequest(
            endpoint: endpoint,
            responseModel: Standalone3dsRes.self,
            timeout: 60)
        return response.resource.data.threeDS.token
    }
}
