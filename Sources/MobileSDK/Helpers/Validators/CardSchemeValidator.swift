//
//  CardIssuerValidator.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import BinProcessing

/**
 A utility object for detecting card schemes based on card numbers.
 Uses the BinProcessing package for BIN lookup (card-schemes.json).
 */
class CardSchemeValidator {

    private let binDetector: CardSchemeDetector

    // MARK: - Initialization

    init(binDetector: CardSchemeDetector) {
        self.binDetector = binDetector
    }

    /// Validates card PAN number using Luhn's algorithm.
    ///
    /// - Parameters:
    ///    - number: Card PAN number that contains only digits with or without whitespaces.
    ///    - Returns: true if valid, false otherwise.
    func isPossibleCreditCardNumber(number: String) -> Bool {
        let cleanNumber = number.filter { !$0.isWhitespace }
        guard containsOnlyNumbers(input: cleanNumber), !cleanNumber.isEmpty else { return false }

        let reversedString = cleanNumber.reversed().compactMap { Int(String($0)) }

        var s1 = 0
        var s2 = 0

        for (index, value) in reversedString.enumerated() {

            if index % 2 == 0 {
                s1 += value
            } else {
                let doubled = value * 2
                s2 += (doubled > 9) ? (doubled - 9) : doubled
            }
        }

        return (s1 + s2) % 10 == 0
    }

    private func containsOnlyNumbers(input: String) -> Bool {
        return input.allSatisfy { chr in
            "1234567890".contains(chr)
        }
    }

    func isCardNumberValid(number: String) -> Bool {
        let cardScheme = getCardSchemeFromBIN(cardNumber: number)
        let isCardNumberLengthValid = isCardNumberLengthValid(number: number, scheme: cardScheme)
        let isCardNumberPossible = isPossibleCreditCardNumber(number: number)

        return cardScheme != nil && isCardNumberLengthValid && isCardNumberPossible
    }

    func getCardSchemeFromBIN(cardNumber: String) -> CardScheme? {
        guard let result = binDetector.detectScheme(pan: cardNumber) else { return nil }
        return CardScheme(rawValue: result.scheme)
    }

    // MARK: - Card number length

    func isCardNumberLengthValid(number: String, scheme: CardScheme?) -> Bool {
        guard let scheme = scheme else { return false }
        return isDigitCountInValidRange(number: number, scheme: scheme)
    }

    func isUnknownCardNumberLengthValid(number: String) -> Bool {
        return isDigitCountInValidRange(number: number, scheme: nil)
    }

    // MARK: - Digit range helpers

    /// Get minimum and maximum digit lengths for a card scheme
    /// - Parameter scheme: The card scheme, or nil for unknown schemes
    /// - Returns: A tuple with (min, max) digit lengths. Defaults to (13, 19) for unknown schemes.
    func digitRange(for scheme: CardScheme?) -> (min: Int, max: Int) {
        guard let scheme = scheme else { return (13, 19) }
        switch scheme {
        case .amex: return (15, 15)
        case .diners: return (14, 14)
        case .visa, .discover, .unionpay: return (16, 19)
        case .mastercard, .japcb: return (16, 16)
        }
    }

    /// Check if digit count is within valid range for scheme
    /// - Parameters:
    ///   - number: The card number string (may contain whitespace or other characters)
    ///   - scheme: The detected card scheme, or nil for unknown schemes
    /// - Returns: true if digit count is within the valid range for the scheme
    func isDigitCountInValidRange(number: String, scheme: CardScheme?) -> Bool {
        let digitCount = number.filter { $0.isNumber }.count
        let range = digitRange(for: scheme)
        return digitCount >= range.min && digitCount <= range.max
    }

    /// Check if digit count meets minimum for scheme
    /// - Parameters:
    ///   - number: The card number string (may contain whitespace or other characters)
    ///   - scheme: The detected card scheme, or nil for unknown schemes
    /// - Returns: true if digit count meets or exceeds the minimum for the scheme
    func hasMinimumDigits(number: String, scheme: CardScheme?) -> Bool {
        let digitCount = number.filter { $0.isNumber }.count
        let range = digitRange(for: scheme)
        return digitCount >= range.min
    }
}
