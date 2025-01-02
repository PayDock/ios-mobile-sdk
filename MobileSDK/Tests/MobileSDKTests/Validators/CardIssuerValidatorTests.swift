//
//  CardIssuerValidatorTests.swift
//  MobileSDK
//
//  Created by Ricardo Da Silva on 2024/12/31.
//

import XCTest
@testable import MobileSDK

struct CardTestCase {
    let cardNumber: String
    let expectedIssuer: CardIssuerType
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
    // Discover
    CardTestCase(cardNumber: "6011111111111117", expectedIssuer: .discover, isValid: true),
    // JCB
    CardTestCase(cardNumber: "3534429687149385", expectedIssuer: .jcb, isValid: true),
    // Solo
    CardTestCase(cardNumber: "6334101999990013", expectedIssuer: .solo, isValid: true),
    CardTestCase(cardNumber: "67675678901234568698", expectedIssuer: .solo, isValid: true),
    // Maestro
    CardTestCase(cardNumber: "5018186568344747", expectedIssuer: .maestro, isValid: true),
    // Union
    CardTestCase(cardNumber: "6250941006528599", expectedIssuer: .unionPay, isValid: true),
    // InterPay
    CardTestCase(cardNumber: "6362970000457013", expectedIssuer: .interPay, isValid: true),
    // InstaPayment
    CardTestCase(cardNumber: "6387249684531166", expectedIssuer: .instaPayment, isValid: true),
    // UATP
    CardTestCase(cardNumber: "1349727835850237", expectedIssuer: .uatp, isValid: true),
    // AUSBC
    CardTestCase(cardNumber: "6771892573677360", expectedIssuer: .ausbc, isValid: true),
    // Invalid number
    CardTestCase(cardNumber: "9234567890123456", expectedIssuer: .other, isValid: false)
]

class CardIssuerValidatorTests: XCTestCase {
    var validator: CardIssuerValidator!

    override func setUp() {
        super.setUp()
        validator = CardIssuerValidator()
    }

    func testDetectCardIssuer() {
        for testCase in testCases {
            let detectedIssuer = validator.detectCardIssuer(number: testCase.cardNumber)
            print("Detected Issuer: \(detectedIssuer)")
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
