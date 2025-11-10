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
    CardTestCase(cardNumber: "6334101999990013", expectedIssuer: .solo, isValid: false),
    CardTestCase(cardNumber: "67675678901234568698", expectedIssuer: .solo, isValid: false),
    // AUSBC
    CardTestCase(cardNumber: "6771892573677360", expectedIssuer: .ausbc, isValid: false),
    CardTestCase(cardNumber: "5610591081018250989", expectedIssuer: .ausbc, isValid: false),
    CardTestCase(cardNumber: "5610591081018250", expectedIssuer: .ausbc, isValid: true),
    // Unionpay
    CardTestCase(cardNumber: "6229293072324646", expectedIssuer: .unionpay, isValid: true),
    CardTestCase(cardNumber: "561059108101850", expectedIssuer: .unionpay, isValid: false),
    CardTestCase(cardNumber: "353442987149385", expectedIssuer: .unionpay, isValid: false)

]

class CardSchemeValidatorTests: XCTestCase {

    var validator: CardSchemeValidator!

    override func setUp() {
        super.setUp()
        validator = CardSchemeValidator()

        let expectation = expectation(description: "Delay for setup")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
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
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "4988"), .visa)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "49899"), .visa)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "4049401"), .visa)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "300"), .diners)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "2221"), .mastercard)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "22222"), .mastercard)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "349013"), .amex)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "372697"), .amex)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "633454"), .solo)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "633461234"), .solo)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "644000123123"), .discover)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "5610"), .ausbc)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "213100"), .japcb)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "622956"), .unionpay)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "622970"), .unionpay)
        XCTAssertEqual(validator.getCardSchemeFromBIN(cardNumber: "626256"), .unionpay)
    }

    func testGetCardSchemeFromBIN_InvalidBIN() {
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "123455"))
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "3915"))
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "0000"))
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "123"))
        XCTAssertNil(validator.getCardSchemeFromBIN(cardNumber: "321"))
    }

    func testIsCardNumberLengthValid_ValidLength() {
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 1111 1111", scheme: .visa))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 444", scheme: .visa))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 33", scheme: .visa))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 11", scheme: .diners))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111", scheme: .mastercard))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111", scheme: .discover))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111", scheme: .japcb))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111", scheme: .solo))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111 111", scheme: .solo))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 111", scheme: .solo))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 11", scheme: .solo))

        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111", scheme: .ausbc))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111 111", scheme: .ausbc))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 111", scheme: .ausbc))
        XCTAssertTrue(validator.isCardNumberLengthValid(number: "5111 1111 1111 11", scheme: .ausbc))

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

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5", scheme: .solo))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111 1111", scheme: .solo))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5", scheme: .ausbc))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "5111 1111 1111 1111 1111", scheme: .ausbc))

        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 1111 111", scheme: .unionpay))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 2222 3333 4444", scheme: .unionpay))
        XCTAssertFalse(validator.isCardNumberLengthValid(number: "4111 1111 2222 32", scheme: .unionpay))
    }
}
