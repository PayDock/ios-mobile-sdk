//
//  CardDetailsFormManagerTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.09.2025..
//  Copyright © 2025 Paydock Ltd.
//

import XCTest
@testable import MobileSDK

// swiftlint:disable file_length large_tuple
// swiftlint:disable:next type_body_length
class CardDetailsFormManagerTests: XCTestCase {

    var sut: CardDetailsFormManager!
    var mockSchemeValidator: MockCardSchemeValidator!
    var mockExpiryValidator: MockCardExpiryDateValidator!
    var mockSecurityCodeValidator: MockCardSecurityCodeValidator!
    var mockNameValidator: MockCardNameValidator!
    var mockFormatter: MockCardDetailsFormatter!

    override func setUp() {
        super.setUp()
        mockSchemeValidator = MockCardSchemeValidator()
        mockExpiryValidator = MockCardExpiryDateValidator()
        mockSecurityCodeValidator = MockCardSecurityCodeValidator()
        mockNameValidator = MockCardNameValidator()
        mockFormatter = MockCardDetailsFormatter()

        sut = CardDetailsFormManager(
            shouldValidateCardholderName: true,
            supportedSchemes: nil,
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )
    }

    override func tearDown() {
        sut = nil
        mockSchemeValidator = nil
        mockExpiryValidator = nil
        mockSecurityCodeValidator = nil
        mockNameValidator = nil
        mockFormatter = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitWithDefaultValues() {
        let manager = CardDetailsFormManager()
        XCTAssertNotNil(manager)
    }

    func testInitialState() {
        XCTAssertEqual(sut.cardholderNameError, "")
        XCTAssertEqual(sut.cardNumberError, "")
        XCTAssertEqual(sut.expiryDateError, "")
        XCTAssertEqual(sut.securityCodeError, "")

        XCTAssertFalse(sut.editingCardholderName)
        XCTAssertFalse(sut.editingCardNumber)
        XCTAssertFalse(sut.editingExpiryDate)
        XCTAssertFalse(sut.editingSecurityCode)

        XCTAssertNil(sut.cardHolderNameValid)
        XCTAssertNil(sut.cardNumberValid)
        XCTAssertNil(sut.expiryDateValid)
        XCTAssertNil(sut.securityCodeValid)

        XCTAssertEqual(sut.cardholderNameTitle, "Cardholder name")
        XCTAssertEqual(sut.cardNumberTitle, "Card number")
        XCTAssertEqual(sut.expiryDateTitle, "Expiry")
        XCTAssertEqual(sut.securityCodeTitle, "CVV")

        XCTAssertEqual(sut.cardholderNamePlaceholder, "")
        XCTAssertEqual(sut.cardNumberPlaceholder, "XXXX XXXX XXXX XXXX")
        XCTAssertEqual(sut.expiryDatePlaceholder, "MM/YY")
        XCTAssertEqual(sut.securityCodePlaceholder, "XXX")

        XCTAssertEqual(sut.cardholderNameText, "")
        XCTAssertEqual(sut.cardNumberText, "")
        XCTAssertEqual(sut.expiryDateText, "")
        XCTAssertEqual(sut.securityCodeText, "")
    }

    // MARK: - Focus Management Tests

    func testSetEditingTextField_CardholderName() {
        sut.setEditingTextField(focusedField: .cardholderName)

        XCTAssertTrue(sut.editingCardholderName)
        XCTAssertFalse(sut.editingCardNumber)
        XCTAssertFalse(sut.editingExpiryDate)
        XCTAssertFalse(sut.editingSecurityCode)
    }

    func testSetEditingTextField_CardNumber() {
        sut.setEditingTextField(focusedField: .cardNumber)

        XCTAssertFalse(sut.editingCardholderName)
        XCTAssertTrue(sut.editingCardNumber)
        XCTAssertFalse(sut.editingExpiryDate)
        XCTAssertFalse(sut.editingSecurityCode)
    }

    func testSetEditingTextField_ExpiryDate() {
        sut.setEditingTextField(focusedField: .expiryDate)

        XCTAssertFalse(sut.editingCardholderName)
        XCTAssertFalse(sut.editingCardNumber)
        XCTAssertTrue(sut.editingExpiryDate)
        XCTAssertFalse(sut.editingSecurityCode)
    }

    func testSetEditingTextField_SecurityCode() {
        sut.setEditingTextField(focusedField: .securityCode)

        XCTAssertFalse(sut.editingCardholderName)
        XCTAssertFalse(sut.editingCardNumber)
        XCTAssertFalse(sut.editingExpiryDate)
        XCTAssertTrue(sut.editingSecurityCode)
    }

    func testEndEditing() {
        sut.setEditingTextField(focusedField: .cardNumber)
        XCTAssertTrue(sut.editingCardNumber)

        sut.endEditing()

        XCTAssertFalse(sut.editingCardholderName)
        XCTAssertFalse(sut.editingCardNumber)
        XCTAssertFalse(sut.editingExpiryDate)
        XCTAssertFalse(sut.editingSecurityCode)
    }

    // MARK: - Cardholder Name Validation Tests

    func testCardholderNameValidation_ValidName() {
        mockNameValidator.isValidNameResult = true
        mockSchemeValidator.isPossibleCreditCardNumberResult = false

        sut.cardholderNameText = "John Doe"

        XCTAssertTrue(sut.cardHolderNameValid ?? false)
        XCTAssertEqual(sut.cardholderNameError, "")
    }

    func testCardholderNameValidation_InvalidName() {
        mockNameValidator.isValidNameResult = false
        mockSchemeValidator.isPossibleCreditCardNumberResult = false

        sut.cardholderNameText = "123"

        XCTAssertFalse(sut.cardHolderNameValid ?? true)
        XCTAssertEqual(sut.cardholderNameError, "Invalid name")
    }

    func testCardholderNameValidation_CardNumberInNameField() {
        mockSchemeValidator.isPossibleCreditCardNumberResult = true

        sut.cardholderNameText = "4111111111111111"

        XCTAssertFalse(sut.cardHolderNameValid ?? true)
        XCTAssertEqual(sut.cardholderNameError, "Card number is in the wrong field!")
    }

    func testCardholderNameValidation_EmptyName() {
        sut.cardholderNameText = ""

        // No validation should occur on empty text
        XCTAssertNil(sut.cardHolderNameValid)
        XCTAssertEqual(sut.cardholderNameError, "")
    }

    // MARK: - Card Number Validation Tests (Disabled Card Validation)

    func testCardNumberValidation_DisabledValidation_ValidCard() {
        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        mockSchemeValidator.isUnknownCardNumberLengthValidResult = true

        sut.cardNumberText = "4111111111111111"

        XCTAssertTrue(sut.cardNumberValid ?? false)
        XCTAssertEqual(sut.cardNumberError, "")
    }

    func testCardNumberValidation_DisabledValidation_InvalidCard() {
        mockSchemeValidator.isPossibleCreditCardNumberResult = false
        mockSchemeValidator.isUnknownCardNumberLengthValidResult = false

        sut.cardNumberText = "123"

        XCTAssertFalse(sut.cardNumberValid ?? true)
        XCTAssertEqual(sut.cardNumberError, "Invalid card number")
    }

    // MARK: - Card Number Validation Tests (Enabled Card Validation)

    func testCardNumberValidation_EnabledValidation_InvalidCard() {
        sut = CardDetailsFormManager(
            enableCardValidation: true,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockSchemeValidator.getCardSchemeFromBINResult = nil
        mockSchemeValidator.isCardNumberValidResult = false
        mockSchemeValidator.isPossibleCreditCardNumberResult = false

        sut.cardNumberText = "123"

        XCTAssertFalse(sut.cardNumberValid ?? true)
        XCTAssertEqual(sut.cardNumberError, "Invalid card number")
    }

    func testCardNumberValidation_EnabledValidation_UnsupportedCardType() {
        sut = CardDetailsFormManager(
            supportedSchemes: [.mastercard],
            enableCardValidation: true,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockSchemeValidator.getCardSchemeFromBINResult = .visa // Not in supported schemes
        mockSchemeValidator.isCardNumberValidResult = true

        sut.cardNumberText = "4111111111111111"

        XCTAssertFalse(sut.cardNumberValid ?? true)
        XCTAssertEqual(sut.cardNumberError, "Card type not accepted")
    }

    // MARK: - Expiry Date Validation Tests

    func testExpiryDateValidation_ValidDate() {
        mockExpiryValidator.validateCreditCardExpiryResult = .valid

        sut.expiryDateText = "12/25"

        XCTAssertTrue(sut.expiryDateValid ?? false)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    func testExpiryDateValidation_ExpiredCard() {
        mockExpiryValidator.validateCreditCardExpiryResult = .expired

        sut.expiryDateText = "01/20"

        XCTAssertFalse(sut.expiryDateValid ?? true)
        XCTAssertEqual(sut.expiryDateError, "Card expired")
    }

    func testExpiryDateValidation_InvalidInput() {
        mockExpiryValidator.validateCreditCardExpiryResult = .invalidInput

        sut.expiryDateText = "13/25"

        XCTAssertFalse(sut.expiryDateValid ?? true)
        XCTAssertEqual(sut.expiryDateError, "Invalid expiry date")
    }

    func testExpiryDateValidation_EmptyDate() {
        sut.expiryDateText = ""

        XCTAssertNil(sut.expiryDateValid)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    // MARK: - Security Code Validation Tests

    func testSecurityCodeValidation_ValidCVV() {
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.securityCodeText = "123"

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")
    }

    func testSecurityCodeValidation_InvalidCVV() {
        mockSecurityCodeValidator.isSecurityCodeValidResult = false
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.securityCodeText = "12"

        XCTAssertFalse(sut.securityCodeValid ?? true)
        XCTAssertEqual(sut.securityCodeError, "Invalid security code")
    }

    func testSecurityCodeValidation_EmptyCode() {
        sut.securityCodeText = ""

        XCTAssertNil(sut.securityCodeValid)
        XCTAssertEqual(sut.securityCodeError, "")
    }

    // MARK: - Security Code Validation Tests (Disabled Card Validation)

    func testSecurityCodeValidation_DisabledValidation_ValidCode() {
        // Set up SUT with disabled card validation
        sut = CardDetailsFormManager(
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockSecurityCodeValidator.isSecurityCodeValidResult = true

        sut.securityCodeText = "123"

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCode, "123")
    }

    func testSecurityCodeValidation_DisabledValidation_InvalidCode() {
        // Set up SUT with disabled card validation
        sut = CardDetailsFormManager(
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockSecurityCodeValidator.isSecurityCodeValidResult = false

        sut.securityCodeText = "12"

        XCTAssertFalse(sut.securityCodeValid ?? true)
        XCTAssertEqual(sut.securityCodeError, "Invalid security code")
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCode, "12")
    }

    func testSecurityCodeValidation_DisabledValidation_FourDigitCode() {
        // Set up SUT with disabled card validation
        sut = CardDetailsFormManager(
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockSecurityCodeValidator.isSecurityCodeValidResult = true

        sut.securityCodeText = "1234"

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCode, "1234")
    }

    func testSecurityCodeValidation_DisabledValidation_EmptyCode() {
        // Set up SUT with disabled card validation
        sut = CardDetailsFormManager(
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        sut.securityCodeText = ""

        XCTAssertNil(sut.securityCodeValid)
        XCTAssertEqual(sut.securityCodeError, "")
        XCTAssertFalse(mockSecurityCodeValidator.isSecurityCodeValidCalled)
    }

    func testSecurityCodeValidation_DisabledValidation_InvalidTooShort() {
        // Set up SUT with disabled card validation
        sut = CardDetailsFormManager(
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockSecurityCodeValidator.isSecurityCodeValidResult = false

        sut.securityCodeText = "1"

        XCTAssertFalse(sut.securityCodeValid ?? true)
        XCTAssertEqual(sut.securityCodeError, "Invalid security code")
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCode, "1")
    }

    func testSecurityCodeValidation_DisabledValidation_InvalidTooLong() {
        // Set up SUT with disabled card validation
        sut = CardDetailsFormManager(
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockSecurityCodeValidator.isSecurityCodeValidResult = false

        sut.securityCodeText = "12345"

        XCTAssertFalse(sut.securityCodeValid ?? true)
        XCTAssertEqual(sut.securityCodeError, "Invalid security code")
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCode, "12345")
    }

    func testSecurityCodeValidation_DisabledValidation_DoesNotDependOnCardScheme() {
        // Set up SUT with disabled card validation
        sut = CardDetailsFormManager(
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = nil // No card scheme detected

        sut.cardNumberText = "1234" // Invalid card number
        sut.securityCodeText = "123"

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCode, "123")
        // The card scheme should not be passed to the validator when validation is disabled
    }

    func testSecurityCodeValidation_DisabledValidation_ValidatesIndependentOfCardNumber() {
        // Set up SUT with disabled card validation
        sut = CardDetailsFormManager(
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockSecurityCodeValidator.isSecurityCodeValidResult = true

        // First test with valid security code and no card number
        sut.securityCodeText = "123"

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")

        // Then test with valid security code and invalid card number
        mockSchemeValidator.isPossibleCreditCardNumberResult = false
        sut.cardNumberText = "invalid"
        sut.securityCodeText = "456"

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")
        XCTAssertEqual(mockSecurityCodeValidator.lastCode, "456")
    }

    // MARK: - Security Code Validation Method Coverage Tests

    func testSecurityCodeValidation_DisabledValidation_CallsCorrectMethod() {
        // Set up SUT with disabled card validation
        sut = CardDetailsFormManager(
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockSecurityCodeValidator.isSecurityCodeValidResult = true

        sut.securityCodeText = "123"

        // Verify the correct method was called and the card scheme was not passed
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCode, "123")
        // When using disabled validation, card scheme should not be relevant
    }

    // MARK: - Security Code Title and Placeholder Updates

    func testUpdateSecurityCodeTitleAndPlaceholder_Visa() {
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.updateSecurityCodeTitleAndPlaceholder()

        XCTAssertEqual(sut.securityCodeTitle, "CVV")
        XCTAssertEqual(sut.securityCodePlaceholder, "XXX")
    }

    func testUpdateSecurityCodeTitleAndPlaceholder_Mastercard() {
        mockSchemeValidator.getCardSchemeFromBINResult = .mastercard

        sut.updateSecurityCodeTitleAndPlaceholder()

        XCTAssertEqual(sut.securityCodeTitle, "CVC")
        XCTAssertEqual(sut.securityCodePlaceholder, "XXX")
    }

    func testUpdateSecurityCodeTitleAndPlaceholder_Amex() {
        mockSchemeValidator.getCardSchemeFromBINResult = .amex

        sut.updateSecurityCodeTitleAndPlaceholder()

        XCTAssertEqual(sut.securityCodeTitle, "CID")
        XCTAssertEqual(sut.securityCodePlaceholder, "XXXX")
    }

    func testUpdateSecurityCodeTitleAndPlaceholder_Discover() {
        mockSchemeValidator.getCardSchemeFromBINResult = .discover

        sut.updateSecurityCodeTitleAndPlaceholder()

        XCTAssertEqual(sut.securityCodeTitle, "CID")
        XCTAssertEqual(sut.securityCodePlaceholder, "XXX")
    }

    func testUpdateSecurityCodeTitleAndPlaceholder_None() {
        mockSchemeValidator.getCardSchemeFromBINResult = nil

        sut.updateSecurityCodeTitleAndPlaceholder()

        XCTAssertEqual(sut.securityCodeTitle, "CVV")
        XCTAssertEqual(sut.securityCodePlaceholder, "XXX")
    }

    // MARK: - Form Validation Tests

    func testIsFormValid_InvalidCardholderName() {
        mockNameValidator.isValidNameResult = false
        mockSchemeValidator.isPossibleCreditCardNumberResult = false // Not a card number in name field
        mockSchemeValidator.isCardNumberValidResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .valid
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.cardholderNameText = "" // Empty name
        sut.cardNumberText = "4111111111111111"
        sut.expiryDateText = "12/25"
        sut.securityCodeText = "123"

        XCTAssertFalse(sut.isFormValid())
    }

    func testIsFormValid_InvalidCardNumber() {
        mockNameValidator.isValidNameResult = true
        mockSchemeValidator.isPossibleCreditCardNumberResult = false
        mockSchemeValidator.isCardNumberValidResult = false
        mockExpiryValidator.validateCreditCardExpiryResult = .valid
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.cardholderNameText = "John Doe"
        sut.cardNumberText = "123"
        sut.expiryDateText = "12/25"
        sut.securityCodeText = "123"

        XCTAssertFalse(sut.isFormValid())
    }

    func testIsFormValid_InvalidExpiryDate() {
        mockNameValidator.isValidNameResult = true
        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        mockSchemeValidator.isCardNumberValidResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .expired
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.cardholderNameText = "John Doe"
        sut.cardNumberText = "4111111111111111"
        sut.expiryDateText = "01/20"
        sut.securityCodeText = "123"

        XCTAssertFalse(sut.isFormValid())
    }

    func testIsFormValid_InvalidSecurityCode() {
        mockNameValidator.isValidNameResult = true
        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        mockSchemeValidator.isCardNumberValidResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .valid
        mockSecurityCodeValidator.isSecurityCodeValidResult = false
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.cardholderNameText = "John Doe"
        sut.cardNumberText = "4111111111111111"
        sut.expiryDateText = "12/25"
        sut.securityCodeText = "12"

        XCTAssertFalse(sut.isFormValid())
    }

    func testIsFormValid_WithCardholderNameValidationDisabled() {
        sut = CardDetailsFormManager(
            shouldValidateCardholderName: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        mockSchemeValidator.isCardNumberValidResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .valid
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.cardholderNameText = "" // Empty but validation is disabled
        sut.cardNumberText = "4111111111111111"
        sut.expiryDateText = "12/25"
        sut.securityCodeText = "123"

        XCTAssertTrue(sut.isFormValid())
    }

    func testIsFormValid_WithCardValidationDisabled_InvalidSecurityCode() {
        sut = CardDetailsFormManager(
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockNameValidator.isValidNameResult = true
        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .valid
        mockSecurityCodeValidator.isSecurityCodeValidResult = false // Invalid security code

        sut.cardholderNameText = "John Doe"
        sut.cardNumberText = "4111111111111111"
        sut.expiryDateText = "12/25"
        sut.securityCodeText = "12" // Too short

        XCTAssertFalse(sut.isFormValid())
    }

    // MARK: - Formatting Tests

    func testFormatCardNumber() {
        let expectedResult = (formattedText: "4111 1111 1111 1111", newCursorPosition: 19)
        mockFormatter.formatCardNumberResult = expectedResult

        let newCursorPosition = sut.formatCardNumber(updatedText: "4111111111111111", cursorPosition: 16)

        XCTAssertEqual(sut.cardNumberText, expectedResult.formattedText)
        XCTAssertEqual(newCursorPosition, expectedResult.newCursorPosition)
        XCTAssertEqual(mockFormatter.formatCardNumberCallCount, 1)
        XCTAssertEqual(mockFormatter.lastCardNumberInput?.updatedText, "4111111111111111")
        XCTAssertEqual(mockFormatter.lastCardNumberInput?.cursorPosition, 16)
    }

    func testFormatExpiryDate() {
        let expectedResult = (formattedText: "12/25", newCursorPosition: 5)
        mockFormatter.formatExpiryDateResult = expectedResult

        let newCursorPosition = sut.formatExpiryDate(updatedText: "1225", cursorPosition: 4)

        XCTAssertEqual(sut.expiryDateText, expectedResult.formattedText)
        XCTAssertEqual(newCursorPosition, expectedResult.newCursorPosition)
        XCTAssertEqual(mockFormatter.formatExpiryDateCallCount, 1)
        XCTAssertEqual(mockFormatter.lastExpiryDateInput?.updatedText, "1225")
        XCTAssertEqual(mockFormatter.lastExpiryDateInput?.cursorPosition, 4)
    }

    func testFormatSecurityCode() {
        let expectedResult = (formattedText: "123", newCursorPosition: 3)
        mockFormatter.formatSecurityCodeResult = expectedResult
        mockSchemeValidator.getCardSchemeFromBINResult = .visa
        mockSecurityCodeValidator.requiredDigitsResult = 3

        let newCursorPosition = sut.formatSecurityCode(updatedText: "123", cursorPosition: 3)

        XCTAssertEqual(sut.securityCodeText, expectedResult.formattedText)
        XCTAssertEqual(newCursorPosition, expectedResult.newCursorPosition)
        XCTAssertEqual(mockFormatter.formatSecurityCodeCallCount, 1)
        XCTAssertEqual(mockFormatter.lastSecurityCodeInput?.updatedText, "123")
        XCTAssertEqual(mockFormatter.lastSecurityCodeInput?.cursorPosition, 3)
        XCTAssertEqual(mockFormatter.lastSecurityCodeInput?.maxDigits, 3)
    }

    func testFormatSecurityCode_WithCardValidationDisabled() {
        // Set up SUT with disabled card validation
        sut = CardDetailsFormManager(
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        let expectedResult = (formattedText: "1234", newCursorPosition: 4)
        mockFormatter.formatSecurityCodeResult = expectedResult

        let newCursorPosition = sut.formatSecurityCode(updatedText: "1234", cursorPosition: 4)

        XCTAssertEqual(sut.securityCodeText, expectedResult.formattedText)
        XCTAssertEqual(newCursorPosition, expectedResult.newCursorPosition)
        XCTAssertEqual(mockFormatter.formatSecurityCodeCallCount, 1)
        XCTAssertEqual(mockFormatter.lastSecurityCodeInput?.updatedText, "1234")
        XCTAssertEqual(mockFormatter.lastSecurityCodeInput?.cursorPosition, 4)
        XCTAssertEqual(mockFormatter.lastSecurityCodeInput?.maxDigits, 4) // Should be 4 when validation is disabled
    }

    // MARK: - Text Property DidSet Tests

    func testCardNumberText_DidSetTriggersValidation() {
        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        mockSchemeValidator.isUnknownCardNumberLengthValidResult = true

        sut.cardNumberText = "4111111111111111"

        XCTAssertTrue(sut.cardNumberValid ?? false)
        XCTAssertEqual(sut.cardNumberError, "")
    }

    func testCardNumberText_DidSetUpdatesCardIcon() {
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.cardNumberText = "4111111111111111"

        // Verify the scheme validator was called
        XCTAssertTrue(mockSchemeValidator.getCardSchemeFromBINCalled)
    }

    func testCardNumberText_DidSetValidatesSecurityCodeIfPresent() {
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.securityCodeText = "123" // Set security code first
        sut.cardNumberText = "4111111111111111" // This should trigger security code validation

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")
    }

    func testExpiryDateText_DidSetTriggersValidation() {
        mockExpiryValidator.validateCreditCardExpiryResult = .valid

        sut.expiryDateText = "12/25"

        XCTAssertTrue(sut.expiryDateValid ?? false)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    func testSecurityCodeText_DidSetTriggersValidation() {
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.securityCodeText = "123"

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")
    }

    func testSecurityCodeText_DidSetTriggersDisabledValidation() {
        // Set up SUT with disabled card validation
        sut = CardDetailsFormManager(
            enableCardValidation: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockSecurityCodeValidator.isSecurityCodeValidResult = true

        sut.securityCodeText = "1234"

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCode, "1234")
    }

    func testCardholderNameText_DidSetTriggersValidation() {
        mockNameValidator.isValidNameResult = true
        mockSchemeValidator.isPossibleCreditCardNumberResult = false

        sut.cardholderNameText = "John Doe"

        XCTAssertTrue(sut.cardHolderNameValid ?? false)
        XCTAssertEqual(sut.cardholderNameError, "")
    }

    // MARK: - Edge Cases

    func testCardNumberValidation_WhenCardholderNameValidationDisabled() {
        sut = CardDetailsFormManager(
            shouldValidateCardholderName: false,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        sut.cardholderNameText = "Some Name"

        // Should not trigger validation when disabled
        XCTAssertNil(sut.cardHolderNameValid)
        XCTAssertEqual(sut.cardholderNameError, "")
    }

    func testSecurityCodeValidation_WithNilCardScheme() {
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = nil // No card scheme detected

        sut.securityCodeText = "123"

        // Should default to visa (3 digits)
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCardScheme, nil)
    }
}

// MARK: - Mock Classes

class MockCardSchemeValidator: CardSchemeValidator {
    var isPossibleCreditCardNumberResult = false
    var isUnknownCardNumberLengthValidResult = false
    var isCardNumberValidResult = false
    var getCardSchemeFromBINResult: CardScheme?

    var isPossibleCreditCardNumberCalled = false
    var isUnknownCardNumberLengthValidCalled = false
    var isCardNumberValidCalled = false
    var getCardSchemeFromBINCalled = false

    var lastCardNumber: String?

    override func isPossibleCreditCardNumber(number: String) -> Bool {
        isPossibleCreditCardNumberCalled = true
        lastCardNumber = number
        return isPossibleCreditCardNumberResult
    }

    override func isUnknownCardNumberLengthValid(number: String) -> Bool {
        isUnknownCardNumberLengthValidCalled = true
        lastCardNumber = number
        return isUnknownCardNumberLengthValidResult
    }

    override func isCardNumberValid(number: String) -> Bool {
        isCardNumberValidCalled = true
        lastCardNumber = number
        return isCardNumberValidResult
    }

    override func getCardSchemeFromBIN(cardNumber: String) -> CardScheme? {
        getCardSchemeFromBINCalled = true
        lastCardNumber = cardNumber
        return getCardSchemeFromBINResult
    }
}

class MockCardExpiryDateValidator: CardExpiryDateValidatior {
    var validateCreditCardExpiryResult: ExpiryValidation = .valid
    var validateCreditCardExpiryCalled = false
    var lastStringDate: String?

    override func validateCreditCardExpiry(stringDate: String) -> ExpiryValidation {
        validateCreditCardExpiryCalled = true
        lastStringDate = stringDate
        return validateCreditCardExpiryResult
    }
}

class MockCardSecurityCodeValidator: CardSecurityCodeValidator {
    var isSecurityCodeValidResult = false
    var requiredDigitsResult = 3

    var isSecurityCodeValidCalled = false
    var requiredDigitsCalled = false

    var lastCode: String?
    var lastCardScheme: CardScheme?

    override func isSecurityCodeValid(code: String, cardScheme: CardScheme) -> Bool {
        isSecurityCodeValidCalled = true
        lastCode = code
        lastCardScheme = cardScheme
        return isSecurityCodeValidResult
    }

    override func isSecurityCodeValidForUnknownScheme(code: String) -> Bool {
        isSecurityCodeValidCalled = true
        lastCode = code
        return isSecurityCodeValidResult
    }

    override func requiredDigits(cardScheme: CardScheme) -> Int {
        requiredDigitsCalled = true
        lastCardScheme = cardScheme
        return requiredDigitsResult
    }
}

class MockCardNameValidator: CardNameValidator {
    var isValidNameResult = false
    var isValidNameCalled = false
    var lastName: String?

    override func isValidName(_ name: String) -> Bool {
        isValidNameCalled = true
        lastName = name
        return isValidNameResult
    }
}

class MockCardDetailsFormatter: CardDetailsFormatter {
    var formatCardNumberResult = (formattedText: "", newCursorPosition: 0)
    var formatExpiryDateResult = (formattedText: "", newCursorPosition: 0)
    var formatSecurityCodeResult = (formattedText: "", newCursorPosition: 0)

    var formatCardNumberCallCount = 0
    var formatExpiryDateCallCount = 0
    var formatSecurityCodeCallCount = 0

    var lastCardNumberInput: (updatedText: String, cursorPosition: Int)?
    var lastExpiryDateInput: (updatedText: String, cursorPosition: Int)?
    var lastSecurityCodeInput: (updatedText: String, cursorPosition: Int, maxDigits: Int)?

    override func formatCardNumber(updatedText: String, cursorPosition: Int) -> (formattedText: String, newCursorPosition: Int) {
        formatCardNumberCallCount += 1
        lastCardNumberInput = (updatedText: updatedText, cursorPosition: cursorPosition)
        return formatCardNumberResult
    }

    override func formatExpiryDate(updatedText: String, cursorPosition: Int) -> (formattedText: String, newCursorPosition: Int) {
        formatExpiryDateCallCount += 1
        lastExpiryDateInput = (updatedText: updatedText, cursorPosition: cursorPosition)
        return formatExpiryDateResult
    }

    override func formatSecurityCode(updatedText: String,
                                     cursorPosition: Int,
                                     maxDigits: Int) -> (formattedText: String, newCursorPosition: Int) {
        formatSecurityCodeCallCount += 1
        lastSecurityCodeInput = (updatedText: updatedText, cursorPosition: cursorPosition, maxDigits: maxDigits)
        return formatSecurityCodeResult
    }
}
// swiftlint:enable file_length large_tuple
