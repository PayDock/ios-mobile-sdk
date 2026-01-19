//
//  ColesPayCallbackRes.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Response model for POST /v1/charges/wallet/callback (Coles Pay)
public struct ColesPayCallbackRes: Codable {
    public let status: Int
    public let resource: ColesPayCallbackResource
}

/// Resource model with returned data
public struct ColesPayCallbackResource: Codable {
    public let type: String
    public let data: CallbackData
}

/// Details of callback response
public struct CallbackData: Codable {
    public let id: String
    public let charge: ColesPayChargeData
}

/// Coles Pay charge data
public struct ColesPayChargeData: Codable {
    public let status: String
}
