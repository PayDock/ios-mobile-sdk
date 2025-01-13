//
//  CardIssuerValidatorTests.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Ricardo Da Silva on 2024/12/31.
//

import XCTest
@testable import MobileSDK

struct CardTestCase {
    let cardNumber: String
    let expectedIssuer: CardScheme
    let isValid: Bool
}

let testCases: [CardTestCase] = [
    // Amex
    CardTestCase(cardNumber: "372015808209082", expectedIssuer: .amex, isValid: true),
    // Visa
    CardTestCase(cardNumber: "4111111111111111", expectedIssuer: .visa, isValid: true),
    // Mastercard
    CardTestCase(cardNumber: "2720994999357329", expectedIssuer: .mastercard, isValid: true),
    CardTestCase(cardNumber: "5555555555554444", expectedIssuer: .mastercard, isValid: true),
    // Diners
    CardTestCase(cardNumber: "30312568541349", expectedIssuer: .diners, isValid: true),
    // JCB
    CardTestCase(cardNumber: "3534429687149385", expectedIssuer: .japcb, isValid: true),
    // Solo
    CardTestCase(cardNumber: "6334101999990013", expectedIssuer: .solo, isValid: true),
    CardTestCase(cardNumber: "67675678901234568698", expectedIssuer: .solo, isValid: true),
    // AUSBC
    CardTestCase(cardNumber: "6771892573677360", expectedIssuer: .ausbc, isValid: true)
]

class CardSchemeValidatorTests: XCTestCase {
    var validator: CardSchemeValidator!

    override func setUp() {
        super.setUp()
        validator = CardSchemeValidator()
    }

    func testDetectCardIssuer() {
        for testCase in testCases {
            let detectedIssuer = validator.detectCardScheme(number: testCase.cardNumber)
            print("Detected Issuer: \(String(describing: detectedIssuer))")
            XCTAssertEqual(detectedIssuer, testCase.expectedIssuer, "Failed for card number: \(testCase.cardNumber)")
        }
    }

    func testIsValidCreditCardNumber() {
        for testCase in testCases {
            let isValid = validator.isValidCreditCardNumber(number: testCase.cardNumber)
            XCTAssertEqual(isValid, testCase.isValid, "Failed for card number: \(testCase.cardNumber)")
        }
    }
}
