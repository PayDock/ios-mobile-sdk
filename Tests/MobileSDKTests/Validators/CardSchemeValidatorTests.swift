//
//  CardIssuerValidatorTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK
import BinProcessing

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
    // Unionpay
    CardTestCase(cardNumber: "6229293072324646", expectedIssuer: .unionpay, isValid: true),
    CardTestCase(cardNumber: "561059108101850", expectedIssuer: .unionpay, isValid: false),
    CardTestCase(cardNumber: "353442987149385", expectedIssuer: .unionpay, isValid: false)
]

class CardSchemeValidatorTests: XCTestCase {

    var validator: CardSchemeValidator!

    override func setUp() {
        super.setUp()
        guard let detector = BinProcessing.makeCardSchemeDetector() else {
            XCTFail("BinProcessing detector could not be loaded")
            return
        }
        validator = CardSchemeValidator(binDetector: detector)
    }

    func testIsPossibleCreditCardNumber_ValidNumbers() {
        XCTAssertTrue(validator.isPossibleCreditCardNumber(number: "4111111111111111")) // Valid Visa
        XCTAssertTrue(validator.isPossibleCreditCardNumber(number: "378282246310005")) // Valid Amex
    }

    func testIsPossibleCreditCardNumber_InvalidNumbers() {
        XCTAssertFalse(validator.isPossibleCreditCardNumber(number: "1234567890123456")) // Invalid
        XCTAssertFalse(validator.isPossibleCreditCardNumber(number: "4111111111111112")) // Invalid Luhn
    }

    func testIsCardNumberValid_ValidCases() {
        testCases.filter({ $0.isValid }).forEach {
            XCTAssertTrue(validator.isCardNumberValid(number: $0.cardNumber))
        }
    }

    func testIsCardNumberValid_InvalidCases() {
        testCases.filter({ !$0.isValid }).forEach {
            XCTAssertFalse(validator.isCardNumberValid(number: $0.cardNumber))
        }
    }

    func testGetCardSchemeFromBIN_ValidBIN() {
        // BinProcessing card-schemes.json (2/4/6/8-digit prefix and ranges)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "41"), .visa)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "4111"), .visa)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "4988"), .visa)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "3000"), .diners)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "2221"), .mastercard)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "2720"), .mastercard)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "34"), .amex)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "372697"), .amex)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "644000"), .discover)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "622956"), .unionpay)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "622970"), .unionpay)
        // 63 -> mastercard, 64 -> discover in BinProcessing data
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "63"), .mastercard)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "64"), .discover)
    }

    func testGetCardSchemeFromBIN_InvalidBIN() {
        // BINs that do not match any scheme in BinProcessing card-schemes.json
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "00"))
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "0012"))
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "12"))
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "1212"))
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "1"))
    }

    func testIsCardNumberLengthValid_ValidLength() {
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 1111 1111", scheme: .visa))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 444", scheme: .visa))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 33", scheme: .visa))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 11", scheme: .diners))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111", scheme: .mastercard))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111", scheme: .discover))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111", scheme: .japcb))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111", scheme: .eftpos))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 1111 1111", scheme: .unionpay))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 444", scheme: .unionpay))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 33", scheme: .unionpay))
    }

    func testIsCardNumberLengthValid_InvalidLength() {
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 1111 111", scheme: .visa))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 4444", scheme: .visa))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 2222 32", scheme: .visa))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "", scheme: .diners))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111", scheme: .diners))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111 123", scheme: .mastercard))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111", scheme: .discover))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5", scheme: .japcb))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111 1111", scheme: .japcb))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 111", scheme: .japcb))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 11", scheme: .japcb))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 111", scheme: .eftpos))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111 1111", scheme: .eftpos))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 11", scheme: .eftpos))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 1111 111", scheme: .unionpay))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 4444", scheme: .unionpay))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 2222 32", scheme: .unionpay))
    }
}
