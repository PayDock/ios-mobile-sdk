//
//  CardTokenRes.swift
//  DataPaymentSources
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import NetworkingLib
import CommonModels

/// Response model for POST /v1/payment_sources/tokens (card tokenization)
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#53e6cf93-480c-4fd3-b7f0-1e9dbd8f5273
public struct OTTTokenRes: Codable {

    /// HTTP status code of the response
    public let status: Int

    /// Resource data containing token information
    public let resource: OTTTokenResource

    public init(status: Int, resource: OTTTokenResource) {
        self.status = status
        self.resource = resource
    }
}

/// Resource wrapper for card token response
public struct OTTTokenResource: Codable {
    /// Resource type identifier
    public let type: String

    /// Token string value (optional, not present in error responses)
    public let data: String?

    public init(type: String, data: String?) {
        self.type = type
        self.data = data
    }
}
