//
//  CardDetailsFormatterTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 28.08.2025..
//  Created by Domagoj Grizelj on 13.01.2025..

//

import XCTest
@testable import MobileSDK

class CardDetailsFormatterTests: XCTestCase {

    var sut: CardDetailsFormatter!

    override func setUp() {
        super.setUp()
        sut = CardDetailsFormatter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Gift Card Number

    func test_formatGiftCardNumber_insertsSpacesEvery4Digits() {
        let result = sut.formatGiftCardNumber(updatedText: "123456789012", cursorPosition: 12)
        XCTAssertEqual(result.formattedText, "1234 5678 9012")
    }

    func test_formatGiftCardNumber_truncatesAt25Digits() {
        let longInput = String(repeating: "1", count: 30)
        let result = sut.formatGiftCardNumber(updatedText: longInput, cursorPosition: 30)
        XCTAssertEqual(result.formattedText.count, 25 + 6) // 25 digits + 6 spaces
    }

    func test_formatGiftCardNumber_ignoresNonDigits() {
        let result = sut.formatGiftCardNumber(updatedText: "12a34b56", cursorPosition: 8)
        XCTAssertEqual(result.formattedText, "1234 56")
    }

    func test_formatGiftCardNumber_adjustsCursorPosition() {
        let result = sut.formatGiftCardNumber(updatedText: "12345", cursorPosition: 5)
        XCTAssertEqual(result.formattedText, "1234 5")
        XCTAssertEqual(result.newCursorPosition, 6) // cursor moved past inserted space
    }

    // MARK: - Card Number

    func test_formatCardNumber_insertsSpacesCorrectly() {
        let result = sut.formatCardNumber(updatedText: "1234567890123456789", cursorPosition: 19)
        XCTAssertEqual(result.formattedText, "1234 5678 9012 3456 789")
    }

    func test_formatCardNumber_truncatesAt23Characters() {
        let longInput = String(repeating: "1", count: 40)
        let result = sut.formatCardNumber(updatedText: longInput, cursorPosition: 40)
        XCTAssertEqual(result.formattedText.count, 23)
    }

    func test_formatCardNumber_preservesUserTypedSpaces() {
        let result = sut.formatCardNumber(updatedText: "1234 5678", cursorPosition: 9)
        XCTAssertEqual(result.formattedText, "1234 5678")
    }

    func test_formatCardNumber_adjustsCursorPosition() {
        let result = sut.formatCardNumber(updatedText: "12345", cursorPosition: 5)
        XCTAssertEqual(result.formattedText, "1234 5")
        XCTAssertEqual(result.newCursorPosition, 6)
    }

    // MARK: - Expiry Date

    func test_formatExpiryDate_insertsSlashAfter2Digits() {
        let result = sut.formatExpiryDate(updatedText: "1225")
        XCTAssertEqual(result, "12/25")
    }

    func test_formatExpiryDate_limitsTo5Characters() {
        let result = sut.formatExpiryDate(updatedText: "12234567")
        XCTAssertEqual(result, "12/23")
    }

    func test_formatExpiryDate_handlesPreTypedSlash() {
        let result = sut.formatExpiryDate(updatedText: "12/34")
        XCTAssertEqual(result, "12/34")
    }

    func test_formatExpiryDate_ignoresNonDigits() {
        let result = sut.formatExpiryDate(updatedText: "1a2b3c")
        XCTAssertEqual(result, "12/3")
    }

    // MARK: - Security Code

    func test_formatSecurityCode_allowsOnlyDigits() {
        let result = sut.formatSecurityCode(updatedText: "12a3b4")
        XCTAssertEqual(result, "1234")
    }

    func test_formatSecurityCode_emptyInput() {
        let result = sut.formatSecurityCode(updatedText: "")
        XCTAssertEqual(result, "")
    }
}
