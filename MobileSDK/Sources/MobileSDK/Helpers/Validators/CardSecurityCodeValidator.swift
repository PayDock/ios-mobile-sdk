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

    func isSecurityCodeValid(code: String, securityCodeType: CardSecurityCodeType) -> Bool {
        return checkSecurityCode(code: code, securityCodeType: securityCodeType) && code.count == securityCodeType.requiredDigits
    }

    /**
     Checks if the security code input is valid based on the specified security code type.

     - Parameters:
        - code: The security code input string to validate.
        - cardSecurityCodeType: The type of security code to validate against.

     - Returns: True if the security code input is valid, false otherwise.
     */
    private func checkSecurityCode(code: String, securityCodeType: CardSecurityCodeType) -> Bool {
        return !code.isEmpty && code.range(of: "^[0-9]+$", options: .regularExpression) != nil && code.count <= securityCodeType.requiredDigits
    }

    /**
     Detects the type of security code based on the specified card issuer type.

     - Parameter cardIssuer: The type of card issuer.

     - Returns: The detected `CardSecurityCodeType` based on the card issuer.
     */
    func detectSecurityCodeType(cardIssuer: CardIssuerType) -> CardSecurityCodeType {
        switch cardIssuer {
        case .visa, .discover, .unionPay:
            return .cvv
        case .amex, .diners:
            return .csc
        case .mastercard:
            return .cvc
        default:
            return .cvv
        }
    }
}
