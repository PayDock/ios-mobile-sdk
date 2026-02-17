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
        guard let scheme = scheme, let regex = cardLengthRegex(for: scheme) else { return false }
        let cleanNumber = number.filter { !$0.isWhitespace }

        let range = NSRange(location: 0, length: cleanNumber.utf16.count)
        let matches = regex.matches(in: cleanNumber, options: [], range: range)

        return !matches.isEmpty
    }

    func isUnknownCardNumberLengthValid(number: String) -> Bool {
        let cleanNumber = number.filter { !$0.isWhitespace }
        return cleanNumber.count >= 12 && cleanNumber.count <= 19
    }

    private func cardLengthRegex(for scheme: CardScheme) -> NSRegularExpression? {
        switch scheme {
        case .amex: return try? NSRegularExpression(pattern: "^\\d{15}$")
        case .diners: return try? NSRegularExpression(pattern: "^\\d{14}$")
        case .visa, .discover, .unionpay: return try? NSRegularExpression(pattern: "^\\d{16,19}$")
        case .mastercard, .japcb, .eftpos: return try? NSRegularExpression(pattern: "^\\d{16}$")
        }
    }
}
