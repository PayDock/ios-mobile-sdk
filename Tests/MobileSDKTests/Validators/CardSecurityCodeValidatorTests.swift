//
//  CardSecurityCodeValidatorTests.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import XCTest
@testable import MobileSDK

class CardSecurityCodeValidatorTests: XCTestCase {

    var validator: CardSecurityCodeValidator!

    override func setUp() {
        super.setUp()
        validator = CardSecurityCodeValidator()
    }

    override func tearDown() {
        validator = nil
        super.tearDown()
    }

    func testValidAmexSecurityCode() {
        XCTAssertTrue(validator.isSecurityCodeValid(code: "1234", cardScheme: .amex))
    }

    func testInvalidAmexSecurityCode_LengthTooShort() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "123", cardScheme: .amex))
    }

    func testInvalidAmexSecurityCode_LengthTooLong() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "12345", cardScheme: .amex))
    }

    func testValidMastercardSecurityCode() {
        XCTAssertTrue(validator.isSecurityCodeValid(code: "123", cardScheme: .mastercard))
    }

    func testInvalidMastercardSecurityCode_LengthTooShort() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "12", cardScheme: .mastercard))
    }

    func testInvalidMastercardSecurityCode_LengthTooLong() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "1234", cardScheme: .mastercard))
    }

    func testInvalidSecurityCode_NonNumericCharacters() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "12a3", cardScheme: .visa))
    }

    func testInvalidSecurityCode_EmptyCode() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "", cardScheme: .visa))
    }

    func testValidVisaSecurityCode() {
        XCTAssertTrue(validator.isSecurityCodeValid(code: "123", cardScheme: .visa))
    }

    func testInvalidVisaSecurityCode_LenghtTooLong() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "1234", cardScheme: .visa))
    }

    func testInvalidVisaSecurityCode_LenghtTooShort() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "12", cardScheme: .visa))
    }

    func testValidDiscoverSecurityCode() {
        XCTAssertTrue(validator.isSecurityCodeValid(code: "123", cardScheme: .discover))
    }

    func testInvalidDiscoverSecurityCode_LenghtTooLong() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "1234", cardScheme: .discover))
    }

    func testInvalidDiscoverSecurityCode_LenghtTooShort() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "12", cardScheme: .discover))
    }

    func testValidDinersSecurityCode() {
        XCTAssertTrue(validator.isSecurityCodeValid(code: "123", cardScheme: .diners))
    }

    func testInvalidDinersSecurityCode_LenghtTooLong() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "1234", cardScheme: .diners))
    }

    func testInvalidDinersSecurityCode_LenghtTooShort() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "12", cardScheme: .diners))
    }

    func testValidJapcbSecurityCode() {
        XCTAssertTrue(validator.isSecurityCodeValid(code: "123", cardScheme: .japcb))
    }

    func testInvalidJapcbSecurityCode_LenghtTooLong() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "1234", cardScheme: .japcb))
    }

    func testInvalidJapcbSecurityCode_LenghtTooShort() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "12", cardScheme: .japcb))
    }

    func testValidUnionpaySecurityCode() {
        XCTAssertTrue(validator.isSecurityCodeValid(code: "123", cardScheme: .unionpay))
    }

    func testInvalidUnionpaySecurityCode_LenghtTooLong() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "1234", cardScheme: .unionpay))
    }

    func testInvalidUnionpaySecurityCode_LenghtTooShort() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "12", cardScheme: .unionpay))
    }

    // MARK: - Tests for isSecurityCodeValidForDisabledValidation

    func testIsSecurityCodeValidForDisabledValidation_Valid3DigitCode() {
        XCTAssertTrue(validator.isSecurityCodeValidForUnknownScheme(code: "123"))
    }

    func testIsSecurityCodeValidForDisabledValidation_Valid4DigitCode() {
        XCTAssertTrue(validator.isSecurityCodeValidForUnknownScheme(code: "1234"))
    }

    func testIsSecurityCodeValidForDisabledValidation_EmptyCode() {
        XCTAssertFalse(validator.isSecurityCodeValidForUnknownScheme(code: ""))
    }

    func testIsSecurityCodeValidForDisabledValidation_TooShort_1Digit() {
        XCTAssertFalse(validator.isSecurityCodeValidForUnknownScheme(code: "1"))
    }

    func testIsSecurityCodeValidForDisabledValidation_TooShort_2Digits() {
        XCTAssertFalse(validator.isSecurityCodeValidForUnknownScheme(code: "12"))
    }

    func testIsSecurityCodeValidForDisabledValidation_TooLong_5Digits() {
        XCTAssertFalse(validator.isSecurityCodeValidForUnknownScheme(code: "12345"))
    }

    func testIsSecurityCodeValidForDisabledValidation_TooLong_6Digits() {
        XCTAssertFalse(validator.isSecurityCodeValidForUnknownScheme(code: "123456"))
    }

    func testIsSecurityCodeValidForDisabledValidation_NonNumericCharacters_Letters() {
        XCTAssertFalse(validator.isSecurityCodeValidForUnknownScheme(code: "12a"))
    }

    func testIsSecurityCodeValidForDisabledValidation_NonNumericCharacters_SpecialChars() {
        XCTAssertFalse(validator.isSecurityCodeValidForUnknownScheme(code: "12#"))
    }

    func testIsSecurityCodeValidForDisabledValidation_NonNumericCharacters_Spaces() {
        XCTAssertFalse(validator.isSecurityCodeValidForUnknownScheme(code: "12 3"))
    }

    func testIsSecurityCodeValidForDisabledValidation_NonNumericCharacters_Mixed() {
        XCTAssertFalse(validator.isSecurityCodeValidForUnknownScheme(code: "1a3"))
    }

    func testIsSecurityCodeValidForDisabledValidation_AllZeros_3Digits() {
        XCTAssertTrue(validator.isSecurityCodeValidForUnknownScheme(code: "000"))
    }

    func testIsSecurityCodeValidForDisabledValidation_AllZeros_4Digits() {
        XCTAssertTrue(validator.isSecurityCodeValidForUnknownScheme(code: "0000"))
    }

    func testIsSecurityCodeValidForDisabledValidation_LeadingZeros_3Digits() {
        XCTAssertTrue(validator.isSecurityCodeValidForUnknownScheme(code: "012"))
    }

    func testIsSecurityCodeValidForDisabledValidation_LeadingZeros_4Digits() {
        XCTAssertTrue(validator.isSecurityCodeValidForUnknownScheme(code: "0123"))
    }

    func testIsSecurityCodeValidForDisabledValidation_AllNines_3Digits() {
        XCTAssertTrue(validator.isSecurityCodeValidForUnknownScheme(code: "999"))
    }

    func testIsSecurityCodeValidForDisabledValidation_AllNines_4Digits() {
        XCTAssertTrue(validator.isSecurityCodeValidForUnknownScheme(code: "9999"))
    }

    func testIsSecurityCodeValidForDisabledValidation_WhitespaceOnly() {
        XCTAssertFalse(validator.isSecurityCodeValidForUnknownScheme(code: "   "))
    }

    func testIsSecurityCodeValidForDisabledValidation_HyphenSeparated() {
        XCTAssertFalse(validator.isSecurityCodeValidForUnknownScheme(code: "12-3"))
    }

    func testIsSecurityCodeValidForDisabledValidation_DotSeparated() {
        XCTAssertFalse(validator.isSecurityCodeValidForUnknownScheme(code: "12.3"))
    }
}
