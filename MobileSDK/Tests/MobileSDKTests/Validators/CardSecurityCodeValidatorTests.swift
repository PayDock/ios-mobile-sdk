//
//  CardSecurityCodeValidatorTests.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.
//  Created by Domagoj Grizelj on 13.01.2025..
//

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

    func testValidSoloSecurityCode() {
        XCTAssertTrue(validator.isSecurityCodeValid(code: "123", cardScheme: .solo))
    }
    
    func testInvalidSoloSecurityCode_LenghtTooShort() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "1234", cardScheme: .solo))
    }
    
    func testInvalidSoloSecurityCode_LenghtTooLong() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "12", cardScheme: .solo))
    }

    func testValidAusbcSecurityCode() {
        XCTAssertTrue(validator.isSecurityCodeValid(code: "123", cardScheme: .ausbc))
    }
    
    func testInvalidAusbcSecurityCode_LenghtTooShort() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "1234", cardScheme: .ausbc))
    }
    
    func testInvalidAusbcSecurityCode_LenghtTooLong() {
        XCTAssertFalse(validator.isSecurityCodeValid(code: "12", cardScheme: .ausbc))
    }
}
