//
//  CardDetailsFormatterTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 28.08.2025..
//  Copyright © 2025 Paydock Ltd.

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
        let result = sut.formatCardNumber(updatedText: "1234567890123456789", cursorPosition: 19, maxDigits: 19)
        XCTAssertEqual(result.formattedText, "1234 5678 9012 3456 789")
    }

    func test_formatCardNumber_truncatesAtMaxDigits() {
        let longInput = String(repeating: "1", count: 40)
        let result = sut.formatCardNumber(updatedText: longInput, cursorPosition: 40, maxDigits: 19)
        XCTAssertEqual(result.formattedText.count, 23) // 19 digits + 4 spaces
    }

    func test_formatCardNumber_truncatesAtAmexMaxDigits() {
        let longInput = String(repeating: "1", count: 20)
        let result = sut.formatCardNumber(updatedText: longInput, cursorPosition: 20, maxDigits: 15)
        XCTAssertEqual(result.formattedText, "1111 1111 1111 111") // 15 digits + 3 spaces
    }

    func test_formatCardNumber_preservesUserTypedSpaces() {
        let result = sut.formatCardNumber(updatedText: "1234 5678", cursorPosition: 9, maxDigits: 19)
        XCTAssertEqual(result.formattedText, "1234 5678")
    }

    func test_formatCardNumber_adjustsCursorPosition() {
        let result = sut.formatCardNumber(updatedText: "12345", cursorPosition: 5, maxDigits: 19)
        XCTAssertEqual(result.formattedText, "1234 5")
        XCTAssertEqual(result.newCursorPosition, 6)
    }

    func test_formatCardNumber_backspaceAtSpacePosition() {
        // Simulates: "4319 4733 0832 5478" with cursor at position 10 (before '0')
        // User presses backspace, which deletes the space at position 9
        // Input becomes "4319 47330832 5478" with cursor at position 9
        let input = "4319 47330832 5478" // Space at position 9 was deleted
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 9, maxDigits: 19)

        // After reformatting, cursor should be at position 9 (after '3', before space)
        XCTAssertEqual(result.formattedText, "4319 4733 0832 5478")
        XCTAssertEqual(result.newCursorPosition, 9)
    }

    func test_formatCardNumber_backspaceDeletesDigitBeforeSpace() {
        // Simulates: "4319 4733 0832 5478" with cursor at position 10 (before '0')
        // User presses backspace twice - first deletes space, second deletes '3'
        // Input becomes "4319 4730832 5478" with cursor at position 8 (after 7 digits)
        let input = "4319 4730832 5478" // Digit '3' and space were deleted
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 8, maxDigits: 19)

        // After reformatting, cursor should be at position 8 (after "4319 473" = 7 digits)
        XCTAssertEqual(result.formattedText, "4319 4730 8325 478")
        XCTAssertEqual(result.newCursorPosition, 8)
    }

    func test_formatCardNumber_cursorInMiddleAfterDeletion() {
        // User deletes a digit in the middle: "4319 4733 0832 5478" -> "4319 433 0832 5478"
        // Cursor should stay in correct position relative to digits
        let input = "4319 433 0832 5478" // '7' was deleted
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 6, maxDigits: 19)

        XCTAssertEqual(result.formattedText, "4319 4330 8325 478")
        XCTAssertEqual(result.newCursorPosition, 6)
    }

    // MARK: - Card Number Max Digits by Scheme

    func test_formatCardNumber_amex_limitsTo15Digits() {
        // Amex: 15 digits max, format 4-6-5
        let input = "378282246310005999" // 18 digits
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 18, maxDigits: 15, spacingPattern: .amex)
        XCTAssertEqual(result.formattedText, "3782 822463 10005") // 15 digits + 2 spaces (4-6-5)
        XCTAssertEqual(result.formattedText.filter { !$0.isWhitespace }.count, 15)
    }

    func test_formatCardNumber_diners_limitsTo14Digits() {
        // Diners: 14 digits max, format 4-6-4
        let input = "3056930009020411999" // 19 digits
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 19, maxDigits: 14, spacingPattern: .diners)
        XCTAssertEqual(result.formattedText, "3056 930009 0204") // 14 digits + 2 spaces (4-6-4)
        XCTAssertEqual(result.formattedText.filter { !$0.isWhitespace }.count, 14)
    }

    func test_formatCardNumber_mastercard_limitsTo16Digits() {
        // Mastercard: 16 digits max
        let input = "5555555555554444999" // 19 digits
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 19, maxDigits: 16)
        XCTAssertEqual(result.formattedText, "5555 5555 5555 4444") // 16 digits + 3 spaces
        XCTAssertEqual(result.formattedText.filter { !$0.isWhitespace }.count, 16)
    }

    func test_formatCardNumber_visa_allows16To19Digits() {
        // Visa: 16-19 digits (test at 16)
        let input16 = "4111111111111111"
        let result16 = sut.formatCardNumber(updatedText: input16, cursorPosition: 16, maxDigits: 19)
        XCTAssertEqual(result16.formattedText, "4111 1111 1111 1111")
        XCTAssertEqual(result16.formattedText.filter { !$0.isWhitespace }.count, 16)

        // Visa: 16-19 digits (test at 19)
        let input19 = "4111111111111111123"
        let result19 = sut.formatCardNumber(updatedText: input19, cursorPosition: 19, maxDigits: 19)
        XCTAssertEqual(result19.formattedText, "4111 1111 1111 1111 123")
        XCTAssertEqual(result19.formattedText.filter { !$0.isWhitespace }.count, 19)
    }

    func test_formatCardNumber_visa_truncatesAt19Digits() {
        // Visa: max 19 digits, should truncate extra
        let input = "41111111111111111234567" // 23 digits
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 23, maxDigits: 19)
        XCTAssertEqual(result.formattedText.filter { !$0.isWhitespace }.count, 19)
    }

    func test_formatCardNumber_unknownScheme_limitsTo19Digits() {
        // Unknown scheme: 12-19 digits, max 19
        let input = String(repeating: "1", count: 25)
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 25, maxDigits: 19)
        XCTAssertEqual(result.formattedText.filter { !$0.isWhitespace }.count, 19)
    }

    func test_formatCardNumber_cursorPositionRespectedWithMaxDigits() {
        // Cursor in middle, max digits applied
        let input = "37828224631000599999" // 20 digits, cursor at 10
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 10, maxDigits: 15)
        XCTAssertEqual(result.formattedText.filter { !$0.isWhitespace }.count, 15)
        XCTAssertLessThanOrEqual(result.newCursorPosition, result.formattedText.count)
    }

    func test_formatCardNumber_emptyInput() {
        let result = sut.formatCardNumber(updatedText: "", cursorPosition: 0, maxDigits: 16)
        XCTAssertEqual(result.formattedText, "")
        XCTAssertEqual(result.newCursorPosition, 0)
    }

    func test_formatCardNumber_ignoresNonDigits() {
        let input = "4111-1111-1111-1111"
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 19, maxDigits: 16)
        XCTAssertEqual(result.formattedText, "4111 1111 1111 1111")
        XCTAssertEqual(result.formattedText.filter { !$0.isWhitespace }.count, 16)
    }

    func test_formatCardNumber_partialInput() {
        // User typing first few digits
        let result = sut.formatCardNumber(updatedText: "3782", cursorPosition: 4, maxDigits: 15)
        XCTAssertEqual(result.formattedText, "3782")
        XCTAssertEqual(result.newCursorPosition, 4)
    }

    // MARK: - Card Number Spacing Patterns

    func test_formatCardNumber_amex_spacingPattern_fullNumber() {
        // Amex: 4-6-5 format
        let input = "378282246310005"
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 15, maxDigits: 15, spacingPattern: .amex)
        XCTAssertEqual(result.formattedText, "3782 822463 10005")
    }

    func test_formatCardNumber_amex_spacingPattern_partial() {
        // Amex partial: should still format correctly during typing
        let input = "37828224"
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 8, maxDigits: 15, spacingPattern: .amex)
        XCTAssertEqual(result.formattedText, "3782 8224")
    }

    func test_formatCardNumber_diners_spacingPattern_fullNumber() {
        // Diners: 4-6-4 format
        let input = "36227206271667"
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 14, maxDigits: 14, spacingPattern: .diners)
        XCTAssertEqual(result.formattedText, "3622 720627 1667")
    }

    func test_formatCardNumber_diners_spacingPattern_partial() {
        // Diners partial: should still format correctly during typing
        let input = "362272062"
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 9, maxDigits: 14, spacingPattern: .diners)
        XCTAssertEqual(result.formattedText, "3622 72062")
    }

    func test_formatCardNumber_standard_spacingPattern_fullNumber() {
        // Standard: 4-4-4-4 format
        let input = "4111111111111111"
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 16, maxDigits: 16, spacingPattern: .standard)
        XCTAssertEqual(result.formattedText, "4111 1111 1111 1111")
    }

    func test_formatCardNumber_amex_cursorAdjustment() {
        // Typing 5th digit in Amex - cursor should adjust for space after 4th digit
        let input = "37828"
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 5, maxDigits: 15, spacingPattern: .amex)
        XCTAssertEqual(result.formattedText, "3782 8")
        XCTAssertEqual(result.newCursorPosition, 6)
    }

    func test_formatCardNumber_amex_cursorAdjustmentAfterSecondGroup() {
        // Typing 11th digit in Amex - cursor should adjust for space after 10th digit
        let input = "37828224631"
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 11, maxDigits: 15, spacingPattern: .amex)
        XCTAssertEqual(result.formattedText, "3782 822463 1")
        XCTAssertEqual(result.newCursorPosition, 13)
    }

    func test_formatCardNumber_diners_cursorAdjustmentAfterSecondGroup() {
        // Typing 11th digit in Diners - cursor should adjust for space after 10th digit
        let input = "36227206271"
        let result = sut.formatCardNumber(updatedText: input, cursorPosition: 11, maxDigits: 14, spacingPattern: .diners)
        XCTAssertEqual(result.formattedText, "3622 720627 1")
        XCTAssertEqual(result.newCursorPosition, 13)
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

    // MARK: - Additional Card Number Input Filtering Tests

    func test_formatCardNumber_filtersNonNumericDuringTyping() {
        // User types letters mixed with numbers
        let result = sut.formatCardNumber(updatedText: "4a1b1c1d1e1f1g1h1", cursorPosition: 18, maxDigits: 16)
        XCTAssertEqual(result.formattedText, "4111 1111 1")
        XCTAssertEqual(result.formattedText.filter { $0.isNumber }.count, 9)
    }

    func test_formatCardNumber_filtersSpecialCharacters() {
        // User pastes card number with dashes
        let result = sut.formatCardNumber(updatedText: "4111-1111-1111-1111", cursorPosition: 19, maxDigits: 16)
        XCTAssertEqual(result.formattedText, "4111 1111 1111 1111")
    }

    func test_formatCardNumber_handlesOnlyLettersInput() {
        // User types only letters
        let result = sut.formatCardNumber(updatedText: "abcdefgh", cursorPosition: 8, maxDigits: 16)
        XCTAssertEqual(result.formattedText, "")
        XCTAssertEqual(result.newCursorPosition, 0)
    }

    func test_formatCardNumber_cursorAdjustsWhenNonDigitsFiltered() {
        // User types "41a1" - cursor at position 4 (after 'a')
        // After filtering, should have "411" with cursor at position 2
        let result = sut.formatCardNumber(updatedText: "41a1", cursorPosition: 3, maxDigits: 16)
        XCTAssertEqual(result.formattedText, "411")
        XCTAssertEqual(result.newCursorPosition, 2)
    }
}
