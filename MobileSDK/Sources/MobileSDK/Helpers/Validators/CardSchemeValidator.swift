//
//  CardIssuerValidator.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 15.08.2023..
//

import Foundation

/**
 A utility object for detecting card schemes based on card numbers
 */
class CardSchemeValidator {

    /**
     Constants for the regex patterns and their corresponding card scheme

     - seealso: CardScheme.visa - Visa cards begin with a 4 and have 13-16-19-digit
     - seealso: CardScheme.mastercard - Mastercard cards begin with a 5 and has 16 digits (51, 52, 53, 54, 55, 222100-272099)
     - seealso: CardScheme.amex - American Express cards begin with a 3, followed by a 4 or a 7 has 15 digits
     - seealso: CardScheme.diners (Diners Club - Carte Blanche) - is a 14-digit number beginning with 300–305,
     - seealso: CardScheme.diners (Diners Club - International) - is a 14-digit number beginning with 36, 38, or
     - seealso: CardScheme.diners (Diners Club - USA & Canada) - is a 16-digit number beginning with 54
     - seealso: CardScheme.japcb - JCB CCN is a 16-19-digit number beginning with 3528 or 3589.
     - seealso: CardScheme.discover - Credit Card Number (Discover) is a 16-19-digit number beginning with 6011, 644–649 or 65.
     */
    private let cardSchemeRegexMap: [NSRegularExpression: CardScheme?] = [
        try! NSRegularExpression(pattern: "^3[47][0-9]{13}$") : .amex,
        try! NSRegularExpression(pattern: "^3(?:0[0-5]|[68][0-9])[0-9]{11}$") : .diners,
        try! NSRegularExpression(pattern: "^4[0-9]{12}(?:[0-9]{3,6})?$") : .visa,
        try! NSRegularExpression(pattern: "^(5[1-5][0-9]{14}|2(22[1-9][0-9]{12}|2[3-9][0-9]{13}|[3-6][0-9]{14}|7[0-1][0-9]{13}|720[0-9]{12}))$") : .mastercard,
        try! NSRegularExpression(pattern: "^6(?:011|5[0-9]{2})[0-9]{12,15}$") : .discover,
        try! NSRegularExpression(pattern: "^(?:2131|1800|35\\d{3})\\d{11}$") : .japcb,
        try! NSRegularExpression(pattern: "^(6334|6767)[0-9]{12}|(6334|6767)[0-9]{14}|(6334|6767)[0-9]{15}$") : .solo,
        try! NSRegularExpression(pattern: "^(5893|6304|677189|67719[0-9])[0-9]{8,15}$") : .ausbc,
        // The generic pattern for all other card schemes
        try! NSRegularExpression(pattern: ".*") : nil
    ]

    /**
     Detects the card scheme based on the provided credit card number using regex patterns.

     - parameter number: The credit card number to detect the scheme for.
     - returns: The `CardScheme` enum representing the detected card issuer, or `nil` if no scheme is matched.
     */
    func detectCardScheme(number: String) -> CardScheme? {
        let cleanNumber = number.filter { !$0.isWhitespace }
        for (regex, issuer) in cardSchemeRegexMap {
            if issuer == nil { continue } // Skip 'other' until all specific patterns are tested
            if let _ = regex.firstMatch(in: cleanNumber, options: [], range: NSRange(location: 0, length: cleanNumber.utf16.count)) {
                return issuer
            }
        }
        return nil
    }

    /// Validates card PAN number using Luhn's algorithm.
    ///
    /// - Parameters:
    ///    - number: Card PAN number that contains only digits with or without whitespaces.
    ///    - Returns: true if valid, false otherwise.
    func isValidCreditCardNumber(number: String) -> Bool {
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
}
