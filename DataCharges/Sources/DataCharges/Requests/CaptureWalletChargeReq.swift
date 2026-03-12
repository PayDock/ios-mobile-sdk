//
//  CaptureWalletChargeReq.swift
//  DataCharges
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import CommonModels

/// Request model for POST /v1/charges/wallet/capture
/// Used to capture a wallet charge after wallet payment authorization
public struct CaptureWalletChargeReq: Codable {
    /// Payment method ID from wallet provider (optional)
    public let paymentMethodId: String?

    /// Customer information (optional)
    public let customer: Customer?

    public init(paymentMethodId: String? = nil,
                customer: Customer? = nil) {
        self.paymentMethodId = paymentMethodId
        self.customer = customer
    }
}
