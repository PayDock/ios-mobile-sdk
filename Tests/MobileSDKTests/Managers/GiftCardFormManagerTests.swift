//
//  GiftCardFormManagerTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.09.2025..
//  Copyright © 2025 Paydock Ltd.

import XCTest
@testable import MobileSDK

class GiftCardFormManagerTests: XCTestCase {

    var sut: GiftCardFormManager!
    var mockFormatter: MockGiftCardDetailsFormatter!

    override func setUp() {
        super.setUp()
        mockFormatter = MockGiftCardDetailsFormatter()
        sut = GiftCardFormManager(cardDetailsFormatter: mockFormatter)
    }

    override func tearDown() {
        sut = nil
        mockFormatter = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitWithDefaultFormatter() {
        let manager = GiftCardFormManager()
        XCTAssertNotNil(manager)
    }

    func testInitWithCustomFormatter() {
        XCTAssertNotNil(sut)
    }

    func testInitialState() {
        XCTAssertEqual(sut.cardNumberError, "")
        XCTAssertEqual(sut.pinError, "")
        XCTAssertFalse(sut.editingCardNumber)
        XCTAssertFalse(sut.editingPin)
        XCTAssertNil(sut.cardNumberValid)
        XCTAssertNil(sut.pinValid)
        XCTAssertEqual(sut.cardNumberTitle, "Card number")
        XCTAssertEqual(sut.pinTitle, "PIN")
        XCTAssertEqual(sut.cardNumberPlaceholder, "XXXX XXXX XXXX XXXX")
        XCTAssertEqual(sut.pinPlaceholder, "XXXX")
        XCTAssertEqual(sut.cardNumberText, "")
        XCTAssertEqual(sut.pinText, "")
    }

    // MARK: - Focus Management Tests

    func testSetEditingTextField_CardNumber() {
        sut.setEditingTextField(focusedField: .cardNumber)

        XCTAssertTrue(sut.editingCardNumber)
        XCTAssertFalse(sut.editingPin)
    }

    func testSetEditingTextField_Pin() {
        sut.setEditingTextField(focusedField: .pin)

        XCTAssertFalse(sut.editingCardNumber)
        XCTAssertTrue(sut.editingPin)
    }

    func testEndEditing() {
        sut.setEditingTextField(focusedField: .cardNumber)
        XCTAssertTrue(sut.editingCardNumber)

        sut.endEditing()

        XCTAssertFalse(sut.editingCardNumber)
        XCTAssertFalse(sut.editingPin)
    }

    // MARK: - Card Number Validation Tests

    func testCardNumberValidation_ValidCardNumber_MinLength() {
        let validCardNumber = "12345678901234" // 14 digits
        sut.cardNumberText = validCardNumber

        XCTAssertTrue(sut.cardNumberValid ?? false)
        XCTAssertEqual(sut.cardNumberError, "")
    }

    func testCardNumberValidation_ValidCardNumber_MaxLength() {
        let validCardNumber = "1234567890123456789012345" // 25 digits
        sut.cardNumberText = validCardNumber

        XCTAssertTrue(sut.cardNumberValid ?? false)
        XCTAssertEqual(sut.cardNumberError, "")
    }

    func testCardNumberValidation_ValidCardNumber_WithSpaces() {
        let validCardNumber = "1234 5678 9012 3456" // 16 digits with spaces
        sut.cardNumberText = validCardNumber

        XCTAssertTrue(sut.cardNumberValid ?? false)
        XCTAssertEqual(sut.cardNumberError, "")
    }

    func testCardNumberValidation_InvalidCardNumber_TooShort() {
        let invalidCardNumber = "123456789012" // 12 digits
        sut.cardNumberText = invalidCardNumber

        XCTAssertFalse(sut.cardNumberValid ?? true)
        XCTAssertEqual(sut.cardNumberError, "Invalid card number")
    }

    func testCardNumberValidation_InvalidCardNumber_TooLong() {
        let invalidCardNumber = "12345678901234567890123456" // 26 digits
        sut.cardNumberText = invalidCardNumber

        XCTAssertFalse(sut.cardNumberValid ?? true)
        XCTAssertEqual(sut.cardNumberError, "Invalid card number")
    }

    func testCardNumberValidation_EmptyCardNumber() {
        sut.cardNumberText = ""

        // Validation only occurs on non-empty text
        XCTAssertNil(sut.cardNumberValid)
        XCTAssertEqual(sut.cardNumberError, "")
    }

    // MARK: - PIN Validation Tests

    func testPinValidation_ValidPin() {
        let validPin = "1234"
        sut.pinText = validPin

        XCTAssertTrue(sut.pinValid ?? false)
        XCTAssertEqual(sut.pinError, "")
    }

    func testPinValidation_InvalidPin_TooShort() {
        let invalidPin = "123"
        sut.pinText = invalidPin

        XCTAssertFalse(sut.pinValid ?? true)
        XCTAssertEqual(sut.pinError, "Invalid PIN number")
    }

    func testPinValidation_InvalidPin_TooLong() {
        let invalidPin = "12345"
        sut.pinText = invalidPin

        XCTAssertFalse(sut.pinValid ?? true)
        XCTAssertEqual(sut.pinError, "Invalid PIN number")
    }

    func testPinValidation_InvalidPin_NonNumeric() {
        let invalidPin = "12a4"
        sut.pinText = invalidPin

        XCTAssertFalse(sut.pinValid ?? true)
        XCTAssertEqual(sut.pinError, "Invalid PIN number")
    }

    func testPinValidation_EmptyPin() {
        sut.pinText = ""

        // Validation only occurs on non-empty text
        XCTAssertNil(sut.pinValid)
        XCTAssertEqual(sut.pinError, "")
    }

    // MARK: - Form Validation Tests

    func testIsFormValid_BothFieldsValid() {
        sut.cardNumberText = "12345678901234"
        sut.pinText = "1234"

        XCTAssertTrue(sut.isFormValid())
    }

    func testIsFormValid_OnlyCardNumberValid() {
        sut.cardNumberText = "12345678901234"
        sut.pinText = "123" // Invalid

        XCTAssertFalse(sut.isFormValid())
    }

    func testIsFormValid_OnlyPinValid() {
        sut.cardNumberText = "123" // Invalid
        sut.pinText = "1234"

        XCTAssertFalse(sut.isFormValid())
    }

    func testIsFormValid_BothFieldsInvalid() {
        sut.cardNumberText = "123" // Invalid
        sut.pinText = "123" // Invalid

        XCTAssertFalse(sut.isFormValid())
    }

    func testIsFormValid_BothFieldsNil() {
        // Default state - no validation has occurred
        XCTAssertFalse(sut.isFormValid())
    }

    // MARK: - Formatting Tests

    func testFormatCardNumber() {
        let expectedResult = (formattedText: "1234 5678", newCursorPosition: 9)
        mockFormatter.formatGiftCardNumberResult = expectedResult

        let actualCursorPosition = sut.formatCardNumber(updatedText: "12345678", cursorPosition: 8)

        XCTAssertEqual(sut.cardNumberText, expectedResult.formattedText)
        XCTAssertEqual(actualCursorPosition, expectedResult.newCursorPosition)
        XCTAssertEqual(mockFormatter.formatGiftCardNumberCallCount, 1)
        XCTAssertEqual(mockFormatter.lastGiftCardNumberInput?.updatedText, "12345678")
        XCTAssertEqual(mockFormatter.lastGiftCardNumberInput?.cursorPosition, 8)
    }

    func testFormatPinNumber() {
        let expectedResult = (formattedText: "1234", newCursorPosition: 4)
        mockFormatter.formatGiftCardPinResult = expectedResult

        let actualCursorPosition = sut.formatPinNumber(updatedText: "1234", cursorPosition: 4)

        XCTAssertEqual(sut.pinText, expectedResult.formattedText)
        XCTAssertEqual(actualCursorPosition, expectedResult.newCursorPosition)
        XCTAssertEqual(mockFormatter.formatGiftCardPinCallCount, 1)
        XCTAssertEqual(mockFormatter.lastGiftCardPinInput?.updatedText, "1234")
        XCTAssertEqual(mockFormatter.lastGiftCardPinInput?.cursorPosition, 4)
    }

    // MARK: - Focus State Validation Tests

    func testSetEditingTextField_ValidatesCurrentField() {
        // Set initial invalid card number
        sut.cardNumberText = "123" // Invalid
        sut.setEditingTextField(focusedField: .cardNumber)

        // Switch to PIN field - should validate the card number
        sut.setEditingTextField(focusedField: .pin)

        XCTAssertFalse(sut.cardNumberValid ?? true)
        XCTAssertEqual(sut.cardNumberError, "Invalid card number")
    }

    // MARK: - Deleting While Focused (Action Button State)

    func testDeletingCardNumberWhileFocused_DisablesForm() {
        sut.setEditingTextField(focusedField: .cardNumber)

        sut.cardNumberText = "12345678901234"
        sut.pinText = "1234"
        XCTAssertTrue(sut.isFormValid(), "Form should be valid with complete card number and PIN")

        sut.cardNumberText = "1234567890123"
        XCTAssertNil(sut.cardNumberValid, "Deleting below valid range should clear cardNumberValid")
        XCTAssertFalse(sut.isFormValid(), "Action button should be disabled when card number becomes invalid")
    }

    func testDeletingPinWhileFocused_DisablesForm() {
        sut.setEditingTextField(focusedField: .pin)

        sut.cardNumberText = "12345678901234"
        sut.pinText = "1234"
        XCTAssertTrue(sut.isFormValid(), "Form should be valid with complete card number and PIN")

        sut.pinText = "123"
        XCTAssertNil(sut.pinValid, "Deleting below 4 digits should clear pinValid")
        XCTAssertFalse(sut.isFormValid(), "Action button should be disabled when PIN becomes invalid")
    }

    // MARK: - Edge Cases

    func testCardNumberText_DidSetTriggersValidation() {
        sut.cardNumberText = "12345678901234"

        XCTAssertTrue(sut.cardNumberValid ?? false)
        XCTAssertEqual(sut.cardNumberError, "")
    }

    func testPinText_DidSetTriggersValidation() {
        sut.pinText = "1234"

        XCTAssertTrue(sut.pinValid ?? false)
        XCTAssertEqual(sut.pinError, "")
    }
}

// MARK: - Mock CardDetailsFormatter

class MockGiftCardDetailsFormatter: CardDetailsFormatter {

    var formatGiftCardNumberCallCount = 0
    var formatGiftCardPinCallCount = 0

    var lastGiftCardNumberInput: (updatedText: String, cursorPosition: Int)?
    var lastGiftCardPinInput: (updatedText: String, cursorPosition: Int)?

    var formatGiftCardNumberResult = (formattedText: "", newCursorPosition: 0)
    var formatGiftCardPinResult = (formattedText: "", newCursorPosition: 0)

    override func formatGiftCardNumber(updatedText: String, cursorPosition: Int) -> (formattedText: String, newCursorPosition: Int) {
        formatGiftCardNumberCallCount += 1
        lastGiftCardNumberInput = (updatedText: updatedText, cursorPosition: cursorPosition)
        return formatGiftCardNumberResult
    }

    override func formatGiftCardPin(updatedText: String, cursorPosition: Int) -> (formattedText: String, newCursorPosition: Int) {
        formatGiftCardPinCallCount += 1
        lastGiftCardPinInput = (updatedText: updatedText, cursorPosition: cursorPosition)
        return formatGiftCardPinResult
    }
}
