//
//  CardDetailsFocusable.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

/// Represents the focusable fields in the card details form.
/// Used for programmatic focus management and scroll-to-error functionality.
public enum CardDetailsFocusable: Hashable {
    case cardholderName
    case cardNumber
    case expiryDate
    case securityCode
}
