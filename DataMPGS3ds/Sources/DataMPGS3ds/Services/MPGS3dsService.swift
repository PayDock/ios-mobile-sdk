//
//  MPGS3dsService.swift
//  DataMPGS3ds
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib

public protocol MPGS3dsService {
    func createMPGS3dsToken(request: MPGS3dsReq, apiAccessToken: String) async throws -> String?
    func createMPGS3dsVaultToken(request: MPGS3dsVaultReq, apiAccessToken: String) async throws -> MPGS3dsRes
}

public struct MPGS3dsServiceImpl: HTTPClient, MPGS3dsService {

    public init() {}

    public func createMPGS3dsToken(request: MPGS3dsReq, apiAccessToken: String) async throws -> String? {
        let endpoint = MPGS3dsEndpoints.mpgs3ds(request: request, apiAccessToken: apiAccessToken)
        let response = try await sendRequest(
            endpoint: endpoint,
            responseModel: MPGS3dsRes.self,
            timeout: 60)
        return response.resource.data.threeDS.token
    }

    public func createMPGS3dsVaultToken(request: MPGS3dsVaultReq, apiAccessToken: String) async throws -> MPGS3dsRes {
        let endpoint = MPGS3dsEndpoints.mpgs3dsVault(request: request, apiAccessToken: apiAccessToken)
        let response = try await sendRequest(
            endpoint: endpoint,
            responseModel: MPGS3dsRes.self,
            timeout: 60)
        return response
    }
}
