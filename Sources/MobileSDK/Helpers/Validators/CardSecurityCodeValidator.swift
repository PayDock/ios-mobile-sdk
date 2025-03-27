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
        return !code.isEmpty && code.range(of: "^[0-9]+$", options: .regularExpression) != nil && code.count <= requiredDigits(cardScheme: cardScheme)
    }
    
    /**
     Checks if the security code input is valid based on the specified security code type.
     
     - Parameters:
     - cardScheme: The card scheme to check.
     
     - Returns: Number of digits required.
     */
    private func requiredDigits(cardScheme: CardScheme) -> Int {
        switch cardScheme {
        case .amex: return 4
        case .mastercard, .visa, .diners, .discover, .japcb, .solo, .ausbc: return 3
        }
    }
}
