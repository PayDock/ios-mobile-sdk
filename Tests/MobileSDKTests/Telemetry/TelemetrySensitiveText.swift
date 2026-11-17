//
//  TelemetrySensitiveText.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

/// Synthetic card-like and email-like text for the no-message-text tests. No real card: the number is built at run
/// time from a synthetic prefix and its Luhn digit, so no card-shaped literal sits in the source.
enum TelemetrySensitiveText {
    static let cardNumber = luhnCompleted("400000000000123")
    static let email = "jane.doe@example.com"
    static let message = "secret-message-text"

    /// The text an error carries in its message, reason or description.
    static let text = "\(message): card \(cardNumber), contact \(email)"

    /// The strings no event or record may hold.
    static let forbidden = [cardNumber, email, message]

    private static func luhnCompleted(_ prefix: String) -> String {
        let digits = prefix.compactMap(\.wholeNumberValue)
        let sum = digits.reversed().enumerated().reduce(0) { total, item in
            guard item.offset.isMultiple(of: 2) else {
                return total + item.element
            }
            let doubled = item.element * 2
            return total + (doubled > 9 ? doubled - 9 : doubled)
        }
        return prefix + String((10 - sum % 10) % 10)
    }
}
