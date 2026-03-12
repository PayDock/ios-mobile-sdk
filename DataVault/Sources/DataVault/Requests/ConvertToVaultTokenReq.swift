//
//  ConvertToVaultTokenReq.swift
//  DataVault
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Request model for POST /v1/vault/payment_sources (convert token to vault token)
/// Based on API documentation: https://documenter.getpostman.com/view/6912944/TzJpifCf#75616a8a-be50-4e45-aca8-23290fb64254
public struct ConvertToVaultTokenReq: Codable {
    /// The payment source token to convert to a vault token (required)
    public let token: String

    /// Vault type: "session" for temporary storage or "permanent" for long-term storage (required)
    public let vaultType: String

    /// Gateway identifier for processing the vault token conversion (optional)
    public let gatewayId: String?

    /// Payment method identifier associated with the token (optional)
    public let paymentMethodId: String?

    /// Convenience initializer for backward compatibility
    public init(token: String, vaultType: String, gatewayId: String? = nil, paymentMethodId: String? = nil) {
        self.token = token
        self.vaultType = vaultType
        self.gatewayId = gatewayId
        self.paymentMethodId = paymentMethodId
    }
}
