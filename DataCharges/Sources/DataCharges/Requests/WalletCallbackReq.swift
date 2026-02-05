//
//  WalletCallbackReq.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation

/// Request model for POST /v1/charges/wallet/callback
/// Used to get callback information for wallet payments
public struct WalletCallbackReq: Codable {
    /// RequestType must be one of the following values: CREATE_TRANSACTION, UPDATE_TRANSACTION,
    /// CREATE_SESSION, GET_SELECTED_PAYMENTS, SET_FINAL_AMOUNT, GET_PAYMENT_ORDER_STATUS,
    /// VOID, CAPTURE" (required)
    public let requestType: String

    /// Whether shipping is requested (optional)
    public let requestShipping: Bool?

    /// Session ID (optional)
    public let sessionId: String?

    /// Wallet type (optional)
    public let walletType: String?

    public init(requestType: String,
                requestShipping: Bool? = nil,
                sessionId: String? = nil,
                walletType: String? = nil) {
        self.requestType = requestType
        self.requestShipping = requestShipping
        self.sessionId = sessionId
        self.walletType = walletType
    }
}
