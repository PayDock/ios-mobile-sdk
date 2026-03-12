//
//  ZipStatus.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

/// Zip payment status codes matching web implementation
/// These are returned in the 'result' query parameter from Zip callbacks
public enum ZipStatus: String, Codable {
    /// Payment was approved successfully
    case approved = "approved"

    /// Payment was declined by Zip
    case declined = "declined"

    /// Payment was cancelled by the user
    case cancelled = "cancelled"

    /// Payment requires manual review (referred)
    case referred = "referred"

    /// Unexpected status received
    case unexpected = "unexpected"

    /// An unexpected error occurred
    case unexpectedError = "unexpected_error"

    /// Whether this status indicates a successful payment
    public var isSuccess: Bool {
        return self == .approved
    }

    /// Whether this status indicates an error that should be reported
    public var isError: Bool {
        return [.declined, .referred, .unexpectedError, .unexpected].contains(self)
    }

    /// Whether this status indicates user cancellation
    public var isCancellation: Bool {
        return self == .cancelled
    }
}

/// Result data from Zip callback
public struct ZipCallbackData {
    /// The status/result of the transaction
    public let status: ZipStatus

    /// The checkout ID from Zip
    public let checkoutId: String?

    /// Additional order ID (legacy parameter)
    public let orderId: String?

    /// The primary identifier (checkoutId or orderId)
    public var identifier: String? {
        return checkoutId ?? orderId
    }
}
