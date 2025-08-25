//
//  CardExpiryDateValidatorTests.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.
//  Created by Domagoj Grizelj on 13.01.2025..
//

import XCTest
@testable import MobileSDK

class CardExpiryDateValidatorTests: XCTestCase {

    var validator: CardExpiryDateValidatior!

    override func setUp() {
        super.setUp()
        validator = CardExpiryDateValidatior()
    }

    override func tearDown() {
        validator = nil
        super.tearDown()
    }

    func testValidExpiryDate() {
        let result = validator.validateCreditCardExpiry(stringDate: "12/30")
        XCTAssertEqual(result, .valid, "Expected .valid for a future date.")
    }

    func testExpiredExpiryDate() {
        let result = validator.validateCreditCardExpiry(stringDate: "01/22")
        XCTAssertEqual(result, .expired, "Expected .expired for a past date.")
    }

    func testInvalidDateInput_EmptyString() {
        let result = validator.validateCreditCardExpiry(stringDate: "")
        XCTAssertEqual(result, .invalidInput, "Expected .invalidInput for an empty string.")
    }

    func testInvalidDateInput_WrongFormat() {
        let result = validator.validateCreditCardExpiry(stringDate: "2023-01")
        XCTAssertEqual(result, .invalidInput, "Expected .invalidInput for a string in the wrong format.")
    }

    func testInvalidDateInput_NonNumeric() {
        let result = validator.validateCreditCardExpiry(stringDate: "AB/CD")
        XCTAssertEqual(result, .invalidInput, "Expected .invalidInput for a non-numeric string.")
    }

    func testEdgeCase_InvalidMonth() {
        let result = validator.validateCreditCardExpiry(stringDate: "13/25")
        XCTAssertEqual(result, .invalidInput, "Expected .invalidInput for an invalid month.")
    }
}
