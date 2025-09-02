//
//  CardDetailsFormatterTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 28.08.2025..
//  Copyright © 2025 Paydock Ltd.
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

    func testTypingMonth() {
        let result = sut.formatExpiryDate(updatedText: "1", cursorPosition: 1)
        XCTAssertEqual(result.formattedText, "1")
        XCTAssertEqual(result.newCursorPosition, 1)

        let result2 = sut.formatExpiryDate(updatedText: "12", cursorPosition: 2)
        XCTAssertEqual(result2.formattedText, "12")
        XCTAssertEqual(result2.newCursorPosition, 2)
    }

    func testSlashAutoInsertion() {
        let result = sut.formatExpiryDate(updatedText: "123", cursorPosition: 3)
        XCTAssertEqual(result.formattedText, "12/3")
        XCTAssertEqual(result.newCursorPosition, 4)
    }

    func testAlreadyTypedSlash() {
        let result = sut.formatExpiryDate(updatedText: "12/3", cursorPosition: 4)
        XCTAssertEqual(result.formattedText, "12/3")
        XCTAssertEqual(result.newCursorPosition, 4)
    }

    func testFullExpiryDate() {
        let result = sut.formatExpiryDate(updatedText: "1227", cursorPosition: 4)
        XCTAssertEqual(result.formattedText, "12/27")
        XCTAssertEqual(result.newCursorPosition, 5)
    }

    func testMaxLength() {
        let result = sut.formatExpiryDate(updatedText: "1223456", cursorPosition: 7)
        XCTAssertEqual(result.formattedText, "12/23")
        XCTAssertEqual(result.newCursorPosition, 5) // capped at end
    }

    func testCursorInsideMonth() {
        let result = sut.formatExpiryDate(updatedText: "1234", cursorPosition: 1)
        XCTAssertEqual(result.formattedText, "12/34")
        XCTAssertEqual(result.newCursorPosition, 1) // cursor stays
    }

    func testCursorBeforeSlashInsertion() {
        // Typing at index 2, slash should not push cursor forward
        let result = sut.formatExpiryDate(updatedText: "123", cursorPosition: 2)
        XCTAssertEqual(result.formattedText, "12/3")
        XCTAssertEqual(result.newCursorPosition, 2)
    }

    // MARK: - Security Code

    func testThreeDigitCVC_allDigits() {
        let result = sut.formatSecurityCode(updatedText: "123", cursorPosition: 3, maxDigits: 3)
        XCTAssertEqual(result.formattedText, "123")
        XCTAssertEqual(result.newCursorPosition, 3)
    }

    func testThreeDigitCVC_moreThanThreeDigits() {
        let result = sut.formatSecurityCode(updatedText: "1234", cursorPosition: 4, maxDigits: 3)
        XCTAssertEqual(result.formattedText, "123")
        XCTAssertEqual(result.newCursorPosition, 3)
    }

    func testThreeDigitCVC_withLettersAndSymbols() {
        let result = sut.formatSecurityCode(updatedText: "1a2!3", cursorPosition: 5, maxDigits: 3)
        XCTAssertEqual(result.formattedText, "123")
        XCTAssertEqual(result.newCursorPosition, 3)
    }

    func testThreeDigitCVC_cursorInMiddle() {
        let result = sut.formatSecurityCode(updatedText: "1a2b3", cursorPosition: 2, maxDigits: 3)
        XCTAssertEqual(result.formattedText, "123")
        XCTAssertEqual(result.newCursorPosition, 1) // cursor after first digit
    }

    func testFourDigitCVC_allDigits() {
        let result = sut.formatSecurityCode(updatedText: "1234", cursorPosition: 4, maxDigits: 4)
        XCTAssertEqual(result.formattedText, "1234")
        XCTAssertEqual(result.newCursorPosition, 4)
    }

    func testFourDigitCVC_moreThanFourDigits() {
        let result = sut.formatSecurityCode(updatedText: "12345", cursorPosition: 5, maxDigits: 4)
        XCTAssertEqual(result.formattedText, "1234")
        XCTAssertEqual(result.newCursorPosition, 4)
    }

    func testFourDigitCVC_withNonDigits() {
        let result = sut.formatSecurityCode(updatedText: "12x3y4", cursorPosition: 6, maxDigits: 4)
        XCTAssertEqual(result.formattedText, "1234")
        XCTAssertEqual(result.newCursorPosition, 4)
    }

    func testEmptyInput() {
        let result = sut.formatSecurityCode(updatedText: "", cursorPosition: 0, maxDigits: 3)
        XCTAssertEqual(result.formattedText, "")
        XCTAssertEqual(result.newCursorPosition, 0)
    }

    func testCursorDoesNotExceedFormattedText() {
        let result = sut.formatSecurityCode(updatedText: "abcd1234", cursorPosition: 8, maxDigits: 3)
        XCTAssertEqual(result.formattedText, "123")
        XCTAssertEqual(result.newCursorPosition, 3)
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

    // MARK: - Gift Card Pin

    func test_formatGiftCardPin_acceptsOnlyDigits() {
        let result = sut.formatGiftCardPin(updatedText: "12a3b", cursorPosition: 5)
        XCTAssertEqual(result.formattedText, "123")
    }

    func test_formatGiftCardPin_truncatesAfter4Digits() {
        let result = sut.formatGiftCardPin(updatedText: "123456789", cursorPosition: 9)
        XCTAssertEqual(result.formattedText, "1234")
        XCTAssertEqual(result.formattedText.count, 4)
    }

    func test_formatGiftCardPin_emptyInput() {
        let result = sut.formatGiftCardPin(updatedText: "", cursorPosition: 0)
        XCTAssertEqual(result.formattedText, "")
        XCTAssertEqual(result.newCursorPosition, 0)
    }

    func test_formatGiftCardPin_updatesCursorPositionCorrectly() {
        // Cursor at end of "123"
        let result = sut.formatGiftCardPin(updatedText: "123", cursorPosition: 3)
        XCTAssertEqual(result.formattedText, "123")
        XCTAssertEqual(result.newCursorPosition, 3)
    }

    func test_formatGiftCardPin_cursorPositionDoesNotExceedLength() {
        // Cursor originally beyond input length
        let result = sut.formatGiftCardPin(updatedText: "12", cursorPosition: 10)
        XCTAssertEqual(result.formattedText, "12")
        XCTAssertEqual(result.newCursorPosition, 2) // capped at length
    }

    func test_formatGiftCardPin_cursorMovesWithValidDigits() {
        let result = sut.formatGiftCardPin(updatedText: "12x3", cursorPosition: 3)
        XCTAssertEqual(result.formattedText, "123")
        XCTAssertEqual(result.newCursorPosition, 2) // after processing "2" at index 1
    }

    func test_formatGiftCardPin_cursorStopsAtMaxDigits() {
        let result = sut.formatGiftCardPin(updatedText: "12345", cursorPosition: 5)
        XCTAssertEqual(result.formattedText, "1234")
        XCTAssertEqual(result.newCursorPosition, 4) // pinned at max digits
    }
}
