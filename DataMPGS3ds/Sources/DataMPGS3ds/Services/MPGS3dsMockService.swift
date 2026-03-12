//
//  MPGS3dsMockService.swift
//  DataMPGS3ds
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import CommonModels

/// Mock service for MPGS3dsService that returns fake data for testing
public struct MPGS3dsMockService: MPGS3dsService {

    public init() {}

    public func createMPGS3dsToken(request: MPGS3dsReq, apiAccessToken: String) async throws -> String? {
        return "mock-mpgs-3ds-token-123"
    }

    public func createMPGS3dsVaultToken(request: MPGS3dsVaultReq, apiAccessToken: String) async throws -> MPGS3dsRes {
        return MPGS3dsRes(
            status: 201,
            resource: MPGS3dsResource(
                type: "charge",
                data: MPGS3dsResponseData(
                    externalId: nil,
                    version: 1,
                    createdAt: "2024-01-01T00:00:00Z",
                    updatedAt: "2024-01-01T00:00:00Z",
                    companyId: "mock-company-123",
                    amount: Decimal(string: request.amount) ?? 0,
                    currency: request.currency,
                    id: "mock-mpgs-charge-123",
                    threeDS: MPGS3dsAuthDetails(id: "mock-mpgs-3ds-id-456", token: "mock-mpgs-3ds-token-456"),
                    transactions: nil,
                    oneOff: true,
                    archived: false,
                    customer: request.customer,
                    capture: true,
                    status: "pre_authentication_pending"
                )
            )
        )
    }
}
