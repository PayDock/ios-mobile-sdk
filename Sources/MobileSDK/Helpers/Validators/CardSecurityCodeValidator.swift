//
//  CardSecurityCodeValidator.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 16.08.2023..
//

import Foundation

/**
 A utility object for detecting the type of security code (CVV, CSC, CVC) based on the card issuer type.
 */
class CardSecurityCodeValidator {

    /**
     Checks if the security code input between 3 or 4 digits.

     - Parameters:
     - code: The security code input string to validate.

     - Returns: True if the security code input is valid, false otherwise.
     */
    func isSecurityCodeValidForUnknownScheme(code: String) -> Bool {
        guard !code.isEmpty,
              code.range(of: "^[0-9]+$", options: .regularExpression) != nil,
              code.count >= 3,
              code.count <= 4 else {
            return false
        }
        return true
    }

    func isSecurityCodeValid(code: String, cardScheme: CardScheme) -> Bool {
        return checkSecurityCode(code: code, cardScheme: cardScheme) && code.count ==  requiredDigits(cardScheme: cardScheme)
    }

    /**
     Checks if the security code input is valid based on the specified security code type.

     - Parameters:
     - code: The security code input string to validate.
     - cardScheme: The type of card scheme to validate against.

     - Returns: True if the security code input is valid, false otherwise.
     */
    private func checkSecurityCode(code: String, cardScheme: CardScheme) -> Bool {
        return !code.isEmpty
            && code.range(of: "^[0-9]+$", options: .regularExpression) != nil
            && code.count <= requiredDigits(cardScheme: cardScheme)
    }

    /**
     Checks if the security code input is valid based on the specified security code type.

     - Parameters:
     - cardScheme: The card scheme to check.

     - Returns: Number of digits required.
     */
    func requiredDigits(cardScheme: CardScheme) -> Int {
        switch cardScheme {
        case .amex: return 4
        case .mastercard, .visa, .diners, .discover, .japcb, .unionpay: return 3
        }
    }
}
