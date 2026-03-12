//
//  Standalone3dsMockService.swift
//  DataStandalone3ds
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Mock service for Standalone3dsService that returns fake data for testing
public struct Standalone3dsMockService: Standalone3dsService {

    public init() {}

    public func createStandalone3DSToken(
        request: Standalone3DSReq, apiAccessToken: String
    ) async throws -> String? {
        return "mock-standalone-3ds-token-123"
    }
}
