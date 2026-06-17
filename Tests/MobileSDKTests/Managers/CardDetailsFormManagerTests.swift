//
//  CardDetailsFormManagerTests.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 01.09.2025..
//  Copyright © 2025 Paydock Ltd.

import XCTest
@testable import MobileSDK
import BinProcessing

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

        // Field placeholders for name/number/expiry are provided via the widget appearance, not
        // the form manager. The form manager only owns the security-code placeholder, which starts
        // empty and is seeded/flipped (XXX <-> XXXX) by updateSecurityCodePlaceholder().
        XCTAssertEqual(sut.securityCodePlaceholder, "")

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

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .cardholderName)
        sut.cardholderNameText = "John Doe"
        sut.setEditingTextField(focusedField: nil)

        XCTAssertTrue(sut.cardHolderNameValid ?? false)
        XCTAssertEqual(sut.cardholderNameError, "")
    }

    func testCardholderNameValidation_InvalidName() {
        mockNameValidator.isValidNameResult = false
        mockSchemeValidator.isPossibleCreditCardNumberResult = false

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .cardholderName)
        sut.cardholderNameText = "123"
        sut.setEditingTextField(focusedField: nil)

        XCTAssertFalse(sut.cardHolderNameValid ?? true)
        XCTAssertEqual(sut.cardholderNameError, "Invalid name")
    }

    func testCardholderNameValidation_CardNumberInNameField() {
        mockSchemeValidator.isPossibleCreditCardNumberResult = true

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .cardholderName)
        sut.cardholderNameText = "4111111111111111"
        sut.setEditingTextField(focusedField: nil)

        XCTAssertFalse(sut.cardHolderNameValid ?? true)
        XCTAssertEqual(sut.cardholderNameError, "Card number is in the wrong field!")
    }

    func testCardholderNameValidation_EmptyName() {
        // Focus field with no input, then defocus
        sut.setEditingTextField(focusedField: .cardholderName)
        sut.cardholderNameText = ""
        sut.setEditingTextField(focusedField: nil)

        // No validation should occur on empty text (no input was made)
        XCTAssertNil(sut.cardHolderNameValid)
        XCTAssertEqual(sut.cardholderNameError, "")
    }

    // MARK: - Active Cardholder Name Validation Tests

    func testCardholderNameValidation_ActiveValidation_CardNumberDetected() {
        mockSchemeValidator.isPossibleCreditCardNumberResult = true

        // Focus field and enter card number - should show error immediately
        sut.setEditingTextField(focusedField: .cardholderName)
        sut.cardholderNameText = "4111111111111111"

        // Error should appear during typing, not just on defocus
        XCTAssertFalse(sut.cardHolderNameValid ?? true)
        XCTAssertEqual(sut.cardholderNameError, "Card number is in the wrong field!")
    }

    func testCardholderNameValidation_ActiveValidation_InvalidCharacters() {
        mockSchemeValidator.isPossibleCreditCardNumberResult = false
        mockNameValidator.containsOnlyAllowedCharactersResult = false

        // Focus field and enter invalid characters - should show error immediately
        sut.setEditingTextField(focusedField: .cardholderName)
        sut.cardholderNameText = "John@Doe"

        // Error should appear during typing
        XCTAssertFalse(sut.cardHolderNameValid ?? true)
        XCTAssertEqual(sut.cardholderNameError, "Invalid name")
    }

    func testCardholderNameValidation_ActiveValidation_StartsWithNonLetter() {
        mockSchemeValidator.isPossibleCreditCardNumberResult = false
        mockNameValidator.containsOnlyAllowedCharactersResult = true
        mockNameValidator.startsWithLetterResult = false

        // Focus field and enter name starting with non-letter
        sut.setEditingTextField(focusedField: .cardholderName)
        sut.cardholderNameText = "-John"

        // Error should appear during typing
        XCTAssertFalse(sut.cardHolderNameValid ?? true)
        XCTAssertEqual(sut.cardholderNameError, "Invalid name")
    }

    func testCardholderNameValidation_ActiveValidation_ValidInput_NoError() {
        mockSchemeValidator.isPossibleCreditCardNumberResult = false
        mockNameValidator.containsOnlyAllowedCharactersResult = true
        mockNameValidator.startsWithLetterResult = true
        mockNameValidator.isValidNameResult = false  // Not fully valid yet (e.g., typing in progress)

        // Focus field and enter partial valid input
        sut.setEditingTextField(focusedField: .cardholderName)
        sut.cardholderNameText = "Joh"

        // No error during typing for partial valid input
        XCTAssertNil(sut.cardHolderNameValid)
        XCTAssertEqual(sut.cardholderNameError, "")
    }

    func testCardholderNameValidation_ActiveValidation_ClearsErrorWhenFixed() {
        mockSchemeValidator.isPossibleCreditCardNumberResult = false

        // Start with invalid characters
        mockNameValidator.containsOnlyAllowedCharactersResult = false
        sut.setEditingTextField(focusedField: .cardholderName)
        sut.cardholderNameText = "John@"

        XCTAssertFalse(sut.cardHolderNameValid ?? true)
        XCTAssertEqual(sut.cardholderNameError, "Invalid name")

        // User fixes the input - make it valid
        mockNameValidator.containsOnlyAllowedCharactersResult = true
        mockNameValidator.startsWithLetterResult = true
        mockNameValidator.isValidNameResult = true
        sut.cardholderNameText = "John Doe"

        // Error should be cleared and name should be valid
        XCTAssertTrue(sut.cardHolderNameValid ?? false)
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

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .expiryDate)
        sut.expiryDateText = "12/25"
        sut.setEditingTextField(focusedField: nil)

        XCTAssertTrue(sut.expiryDateValid ?? false)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    func testExpiryDateValidation_ExpiredCard() {
        mockExpiryValidator.validateCreditCardExpiryResult = .expired

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .expiryDate)
        sut.expiryDateText = "01/20"
        sut.setEditingTextField(focusedField: nil)

        XCTAssertFalse(sut.expiryDateValid ?? true)
        XCTAssertEqual(sut.expiryDateError, "Card expired")
    }

    func testExpiryDateValidation_InvalidInput() {
        mockExpiryValidator.validateCreditCardExpiryResult = .invalidInput

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .expiryDate)
        sut.expiryDateText = "13/25"
        sut.setEditingTextField(focusedField: nil)

        XCTAssertFalse(sut.expiryDateValid ?? true)
        XCTAssertEqual(sut.expiryDateError, "Invalid expiry date")
    }

    func testExpiryDateValidation_EmptyDate() {
        // Focus field with no input, then defocus
        sut.setEditingTextField(focusedField: .expiryDate)
        sut.expiryDateText = ""
        sut.setEditingTextField(focusedField: nil)

        XCTAssertNil(sut.expiryDateValid)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    // MARK: - Expiry Date Active Validation Tests

    func testExpiryDateValidation_InvalidMonthAt2ndDigit() {
        mockExpiryValidator.validateMonthResult = false

        // Focus the field for active validation during typing
        sut.setEditingTextField(focusedField: .expiryDate)

        // Simulate typing month "13" (invalid)
        sut.expiryDateText = "1"  // 1 digit - no validation yet
        XCTAssertNil(sut.expiryDateValid)

        sut.expiryDateText = "13" // 2 digits - validates month
        XCTAssertFalse(sut.expiryDateValid ?? true)
        XCTAssertEqual(sut.expiryDateError, "Invalid month")
    }

    func testExpiryDateValidation_ValidMonthAt2ndDigit() {
        mockExpiryValidator.validateMonthResult = true

        // Focus the field for active validation during typing
        sut.setEditingTextField(focusedField: .expiryDate)

        // Simulate typing month "12" (valid)
        sut.expiryDateText = "1"  // 1 digit - no validation yet
        XCTAssertNil(sut.expiryDateValid)

        sut.expiryDateText = "12" // 2 digits - validates month
        // Valid month, but not fully valid until 4th digit
        XCTAssertNil(sut.expiryDateValid)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    func testExpiryDateValidation_FullDateAt4thDigit() {
        mockExpiryValidator.validateMonthResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .valid

        // Focus the field for active validation during typing
        sut.setEditingTextField(focusedField: .expiryDate)

        // Simulate typing full date
        sut.expiryDateText = "12"    // 2 digits - month valid
        sut.expiryDateText = "12/2"  // 3 digits - no full validation yet
        XCTAssertNil(sut.expiryDateValid)

        sut.expiryDateText = "12/25" // 4 digits - full validation
        XCTAssertTrue(sut.expiryDateValid ?? false)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    func testExpiryDateValidation_ExpiredCardAt4thDigit() {
        mockExpiryValidator.validateMonthResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .expired

        // Focus the field for active validation during typing
        sut.setEditingTextField(focusedField: .expiryDate)

        sut.expiryDateText = "01/20" // 4 digits - full validation shows expired
        XCTAssertFalse(sut.expiryDateValid ?? true)
        XCTAssertEqual(sut.expiryDateError, "Card expired")
    }

    func testExpiryDateValidation_RevalidatesOnEdit() {
        mockExpiryValidator.validateMonthResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .valid

        // Focus the field for active validation during typing
        sut.setEditingTextField(focusedField: .expiryDate)

        // Enter valid date
        sut.expiryDateText = "12/25"
        XCTAssertTrue(sut.expiryDateValid ?? false)

        // Edit to invalid (delete to 2 digits)
        mockExpiryValidator.validateMonthResult = false
        sut.expiryDateText = "13"
        XCTAssertFalse(sut.expiryDateValid ?? true)
        XCTAssertEqual(sut.expiryDateError, "Invalid month")
    }

    func testExpiryDateValidation_ClearsErrorOnDelete() {
        mockExpiryValidator.validateMonthResult = false

        // Focus the field for active validation during typing
        sut.setEditingTextField(focusedField: .expiryDate)

        // Enter invalid month
        sut.expiryDateText = "13"
        XCTAssertFalse(sut.expiryDateValid ?? true)
        XCTAssertEqual(sut.expiryDateError, "Invalid month")

        // Delete to 1 digit - error should clear
        sut.expiryDateText = "1"
        XCTAssertNil(sut.expiryDateValid)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    func testExpiryDateValidation_ClearsOnEmpty() {
        mockExpiryValidator.validateCreditCardExpiryResult = .valid

        // Focus the field for active validation during typing
        sut.setEditingTextField(focusedField: .expiryDate)

        // Enter valid date
        sut.expiryDateText = "12/25"
        XCTAssertTrue(sut.expiryDateValid ?? false)

        // Clear all input
        sut.expiryDateText = ""
        XCTAssertNil(sut.expiryDateValid)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    func testExpiryDateValidation_ClearsExpiredErrorOnDeleteToMonth() {
        // Scenario: User enters expired date, then deletes back to edit
        mockExpiryValidator.validateMonthResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .expired

        // Focus the field for active validation during typing
        sut.setEditingTextField(focusedField: .expiryDate)

        // Enter expired date - shows "Card expired" error
        sut.expiryDateText = "01/20"
        XCTAssertFalse(sut.expiryDateValid ?? true)
        XCTAssertEqual(sut.expiryDateError, "Card expired")

        // Delete back to just month (2 digits) - "Card expired" should clear
        // because we're now only validating the month, not the full date
        sut.expiryDateText = "01"
        XCTAssertNil(sut.expiryDateValid)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    func testExpiryDateValidation_ClearsExpiredErrorOnDeleteToThreeDigits() {
        // Scenario: User enters expired date, then deletes one digit
        mockExpiryValidator.validateMonthResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .expired

        // Focus the field for active validation during typing
        sut.setEditingTextField(focusedField: .expiryDate)

        // Enter expired date
        sut.expiryDateText = "01/20"
        XCTAssertEqual(sut.expiryDateError, "Card expired")

        // Delete to 3 digits - "Card expired" should clear
        sut.expiryDateText = "01/2"
        XCTAssertNil(sut.expiryDateValid)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    func testExpiryDateValidation_CanFixExpiredDateByReentering() {
        mockExpiryValidator.validateMonthResult = true

        // Focus the field for active validation during typing
        sut.setEditingTextField(focusedField: .expiryDate)

        // Enter expired date
        mockExpiryValidator.validateCreditCardExpiryResult = .expired
        sut.expiryDateText = "01/20"
        XCTAssertEqual(sut.expiryDateError, "Card expired")

        // Delete back to month
        sut.expiryDateText = "01"
        XCTAssertEqual(sut.expiryDateError, "")

        // Enter valid year - should now be valid
        mockExpiryValidator.validateCreditCardExpiryResult = .valid
        sut.expiryDateText = "01/30"
        XCTAssertTrue(sut.expiryDateValid ?? false)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    // MARK: - Security Code Validation Tests

    func testSecurityCodeValidation_ValidCVV() {
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "123"
        sut.setEditingTextField(focusedField: nil)

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")
    }

    func testSecurityCodeValidation_InvalidCVV() {
        mockSecurityCodeValidator.isSecurityCodeValidResult = false
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "12"
        sut.setEditingTextField(focusedField: nil)

        XCTAssertFalse(sut.securityCodeValid ?? true)
        XCTAssertEqual(sut.securityCodeError, "Invalid security code")
    }

    func testSecurityCodeValidation_EmptyCode() {
        // Focus field with no input, then defocus
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = ""
        sut.setEditingTextField(focusedField: nil)

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

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "123"
        sut.setEditingTextField(focusedField: nil)

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

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "12"
        sut.setEditingTextField(focusedField: nil)

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

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "1234"
        sut.setEditingTextField(focusedField: nil)

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

        // Focus field with no input, then defocus
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = ""
        sut.setEditingTextField(focusedField: nil)

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

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "1"
        sut.setEditingTextField(focusedField: nil)

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

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "12345"
        sut.setEditingTextField(focusedField: nil)

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
        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "123"
        sut.setEditingTextField(focusedField: nil)

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCode, "123")
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
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "123"
        sut.setEditingTextField(focusedField: nil)

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")

        // Then test with valid security code and invalid card number
        mockSchemeValidator.isPossibleCreditCardNumberResult = false
        sut.cardNumberText = "invalid"
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "456"
        sut.setEditingTextField(focusedField: nil)

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

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "123"
        sut.setEditingTextField(focusedField: nil)

        // Verify the correct method was called and the card scheme was not passed
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCode, "123")
    }

    // MARK: - Security Code Title and Placeholder Updates

    // The security-code title is a constant "CVV"; updateSecurityCodePlaceholder() flips the
    // placeholder between the "XXX" and "XXXX" sentinels (amex uses 4 digits) from a seeded value,
    // leaving any custom override untouched.
    func testUpdateSecurityCodePlaceholder_Visa() {
        mockSchemeValidator.getCardSchemeFromBINResult = .visa
        sut.securityCodePlaceholder = "XXX"

        sut.updateSecurityCodePlaceholder()

        XCTAssertEqual(sut.securityCodeTitle, "CVV")
        XCTAssertEqual(sut.securityCodePlaceholder, "XXX")
    }

    func testUpdateSecurityCodePlaceholder_Mastercard() {
        mockSchemeValidator.getCardSchemeFromBINResult = .mastercard
        sut.securityCodePlaceholder = "XXX"

        sut.updateSecurityCodePlaceholder()

        XCTAssertEqual(sut.securityCodeTitle, "CVV")
        XCTAssertEqual(sut.securityCodePlaceholder, "XXX")
    }

    func testUpdateSecurityCodePlaceholder_Amex() {
        mockSchemeValidator.getCardSchemeFromBINResult = .amex
        sut.securityCodePlaceholder = "XXX"

        sut.updateSecurityCodePlaceholder()

        XCTAssertEqual(sut.securityCodeTitle, "CVV")
        XCTAssertEqual(sut.securityCodePlaceholder, "XXXX")
    }

    func testUpdateSecurityCodePlaceholder_Discover() {
        mockSchemeValidator.getCardSchemeFromBINResult = .discover
        sut.securityCodePlaceholder = "XXX"

        sut.updateSecurityCodePlaceholder()

        XCTAssertEqual(sut.securityCodeTitle, "CVV")
        XCTAssertEqual(sut.securityCodePlaceholder, "XXX")
    }

    func testUpdateSecurityCodePlaceholder_None() {
        mockSchemeValidator.getCardSchemeFromBINResult = nil
        sut.securityCodePlaceholder = "XXX"

        sut.updateSecurityCodePlaceholder()

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

    func testIsFormValid_WithCardValidationEnabled_UnsupportedCardType() {
        sut = CardDetailsFormManager(
            supportedSchemes: [.visa],
            enableCardValidation: true,
            cardIssuerValidator: mockSchemeValidator,
            cardExpiryDateValidator: mockExpiryValidator,
            cardSecurityCodeValidator: mockSecurityCodeValidator,
            cardExpiryDateFormatter: mockFormatter,
            cardNameValidator: mockNameValidator
        )

        mockNameValidator.isValidNameResult = true
        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        mockSchemeValidator.isCardNumberValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .mastercard // Not in supported schemes (Visa only)
        mockExpiryValidator.validateCreditCardExpiryResult = .valid
        mockSecurityCodeValidator.isSecurityCodeValidResult = true

        sut.cardholderNameText = "John Doe"
        sut.cardNumberText = "5123456789012346"
        sut.expiryDateText = "12/25"
        sut.securityCodeText = "123"

        XCTAssertFalse(sut.cardNumberValid ?? true, "Card type not accepted should set cardNumberValid to false")
        XCTAssertEqual(sut.cardNumberError, "Card type not accepted")
        XCTAssertFalse(sut.isFormValid(), "Submit should be disabled when card type is not accepted")
    }

    // MARK: - validateForm() / first-error targeting

    func testValidateForm_AllValid_ReturnsTrueWithNoFirstError() {
        // Name collection disabled so isFormValid's name check is bypassed, leaving a cleanly valid form.
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

        sut.cardNumberText = "4111111111111111"
        sut.expiryDateText = "12/25"
        sut.securityCodeText = "123"

        XCTAssertTrue(sut.validateForm())
        XCTAssertNil(sut.firstFieldWithError)
    }

    /// Regression: when cardholder-name collection is disabled, the never-validated (nil) name must
    /// NOT be treated as the first error or counted — the first invalid *collected* field wins.
    /// Previously `cardHolderNameValid != true` flagged the (nil) name as the first error.
    func testValidateForm_NameCollectionDisabled_DoesNotFlagCardholderName() {
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
        mockExpiryValidator.validateCreditCardExpiryResult = .expired // only the expiry is invalid
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.cardNumberText = "4111111111111111"
        sut.expiryDateText = "01/20"
        sut.securityCodeText = "123"

        XCTAssertFalse(sut.validateForm())
        XCTAssertEqual(sut.firstFieldWithError, .expiryDate, "First error should be the expiry, not the un-collected name")
        XCTAssertNil(sut.cardHolderNameValid, "Name should never be validated when collection is disabled")
        XCTAssertEqual(sut.numberOfValidationFailures, 1, "The un-collected name must not be counted as an error")
    }

    func testValidateForm_NameCollected_InvalidName_FirstErrorIsCardholderName() {
        // Default `sut` collects the cardholder name.
        mockNameValidator.isValidNameResult = false // name invalid
        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        mockSchemeValidator.isCardNumberValidResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .valid
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.cardholderNameText = "John Doe"
        sut.cardNumberText = "4111111111111111"
        sut.expiryDateText = "12/25"
        sut.securityCodeText = "123"

        XCTAssertFalse(sut.validateForm())
        XCTAssertEqual(sut.firstFieldWithError, .cardholderName)
    }

    func testValidateForm_InvalidExpiry_FirstErrorIsExpiry() {
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

        XCTAssertFalse(sut.validateForm())
        XCTAssertEqual(sut.firstFieldWithError, .expiryDate)
        XCTAssertEqual(sut.numberOfValidationFailures, 1)
    }

    /// Regression: `firstFieldWithError` must be recomputed each submit, not retain a stale field
    /// from a previous submit (the cardholder name here, which is fixed before the second submit).
    func testValidateForm_ResetsStaleFirstFieldBetweenSubmits() {
        mockNameValidator.isValidNameResult = false // name invalid on first submit
        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        mockSchemeValidator.isCardNumberValidResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .valid
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.cardholderNameText = "John Doe"
        sut.cardNumberText = "4111111111111111"
        sut.expiryDateText = "12/25"
        sut.securityCodeText = "123"

        XCTAssertFalse(sut.validateForm())
        XCTAssertEqual(sut.firstFieldWithError, .cardholderName)

        // Fix the name, break only the expiry, and resubmit.
        mockNameValidator.isValidNameResult = true
        mockExpiryValidator.validateCreditCardExpiryResult = .expired
        sut.expiryDateText = "01/20"

        XCTAssertFalse(sut.validateForm())
        XCTAssertEqual(sut.firstFieldWithError, .expiryDate, "Stale cardholderName must not survive the second submit")
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

    func testExpiryDateText_ActiveValidationDuringTyping() {
        // Expiry validates actively at 2nd digit (month) and 4th digit (full date)
        mockExpiryValidator.validateCreditCardExpiryResult = .valid

        // Focus the field for active validation during typing
        sut.setEditingTextField(focusedField: .expiryDate)

        // Setting full date "12/25" (4 digits) triggers immediate validation
        sut.expiryDateText = "12/25"

        // Full validation happens at 4th digit
        XCTAssertTrue(sut.expiryDateValid ?? false)
        XCTAssertEqual(sut.expiryDateError, "")
    }

    func testSecurityCodeText_DidSetTracksInput() {
        // DidSet should track input but not trigger validation (validation on defocus)
        mockSecurityCodeValidator.isSecurityCodeValidResult = true
        mockSchemeValidator.getCardSchemeFromBINResult = .visa

        sut.securityCodeText = "123"

        // No validation during typing - validation happens on defocus
        XCTAssertNil(sut.securityCodeValid)
        XCTAssertEqual(sut.securityCodeError, "")

        // Now defocus to trigger validation
        sut.setEditingTextField(focusedField: .securityCode)
        sut.setEditingTextField(focusedField: nil)

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

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "1234"
        sut.setEditingTextField(focusedField: nil)

        XCTAssertTrue(sut.securityCodeValid ?? false)
        XCTAssertEqual(sut.securityCodeError, "")
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCode, "1234")
    }

    func testCardholderNameText_DidSetTracksInput() {
        // DidSet should track input but not trigger validation (validation on defocus)
        mockNameValidator.isValidNameResult = true
        mockSchemeValidator.isPossibleCreditCardNumberResult = false

        sut.cardholderNameText = "John Doe"

        // No validation during typing - validation happens on defocus
        XCTAssertNil(sut.cardHolderNameValid)
        XCTAssertEqual(sut.cardholderNameError, "")

        // Now defocus to trigger validation
        sut.setEditingTextField(focusedField: .cardholderName)
        sut.setEditingTextField(focusedField: nil)

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

        // Focus field, enter data, then defocus to trigger validation
        sut.setEditingTextField(focusedField: .securityCode)
        sut.securityCodeText = "123"
        sut.setEditingTextField(focusedField: nil)

        // Should validate with no card scheme
        XCTAssertTrue(mockSecurityCodeValidator.isSecurityCodeValidCalled)
        XCTAssertEqual(mockSecurityCodeValidator.lastCardScheme, nil)
    }

    // MARK: - Card Number Validation Timing Tests

    func testCardNumberValidation_DuringTyping_DoesNotShowErrorWhenBelowMinimum() {
        // Setup: User is typing card number, digit count below minimum
        mockSchemeValidator.getCardSchemeFromBINResult = .visa // Visa requires 16-19 digits
        mockSchemeValidator.isDigitCountInValidRangeResult = false // Below minimum (e.g., 10 digits)
        mockSchemeValidator.isPossibleCreditCardNumberResult = false // Luhn would fail

        // Simulate typing - field is being edited
        sut.setEditingTextField(focusedField: .cardNumber)
        sut.cardNumberText = "4111111111" // 10 digits, below Visa minimum of 16

        // Should not show error during typing when below minimum
        // Error will be shown on defocus instead
        XCTAssertNil(sut.cardNumberValid)
        XCTAssertEqual(sut.cardNumberError, "")
        // Luhn check should not be called when digit count is below minimum
        XCTAssertFalse(mockSchemeValidator.isPossibleCreditCardNumberCalled)
    }

    func testCardNumberValidation_DuringTyping_ShowsErrorWhenInValidRangeAndLuhnFails() {
        // Setup: User is typing card number, digit count in valid range
        mockSchemeValidator.getCardSchemeFromBINResult = .visa
        mockSchemeValidator.isDigitCountInValidRangeResult = true // In valid range (e.g., 16 digits)
        mockSchemeValidator.isPossibleCreditCardNumberResult = false // Luhn fails
        mockSchemeValidator.isCardNumberValidResult = false

        // Simulate typing - field is being edited
        sut.setEditingTextField(focusedField: .cardNumber)
        sut.cardNumberText = "4111111111111112" // 16 digits, invalid Luhn

        // Should show error when digit count is in valid range and Luhn fails
        XCTAssertFalse(sut.cardNumberValid ?? true)
        XCTAssertEqual(sut.cardNumberError, "Invalid card number")
        XCTAssertTrue(mockSchemeValidator.isPossibleCreditCardNumberCalled)
    }

    func testCardNumberValidation_OnDefocus_ShowsErrorWhenBelowMinimum() {
        // Setup: User defocuses field with insufficient digits
        mockSchemeValidator.getCardSchemeFromBINResult = .visa
        mockSchemeValidator.hasMinimumDigitsResult = false // Below minimum
        mockSchemeValidator.isDigitCountInValidRangeResult = false

        // Simulate typing then defocusing
        sut.setEditingTextField(focusedField: .cardNumber)
        sut.cardNumberText = "4111111111" // 10 digits, below Visa minimum
        sut.setEditingTextField(focusedField: nil) // Defocus

        // Should show error on defocus when below minimum
        XCTAssertFalse(sut.cardNumberValid ?? true)
        XCTAssertEqual(sut.cardNumberError, "Invalid card number")
        XCTAssertTrue(mockSchemeValidator.hasMinimumDigitsCalled)
    }

    func testCardNumberValidation_OnDefocus_ValidatesWhenMinimumMet() {
        // Setup: User defocuses field with sufficient digits
        mockSchemeValidator.getCardSchemeFromBINResult = .visa
        mockSchemeValidator.hasMinimumDigitsResult = true // Meets minimum
        mockSchemeValidator.isCardNumberValidResult = true
        mockSchemeValidator.isPossibleCreditCardNumberResult = true

        // Simulate typing then defocusing
        sut.setEditingTextField(focusedField: .cardNumber)
        sut.cardNumberText = "4111111111111111" // 16 digits, valid Visa
        sut.setEditingTextField(focusedField: nil) // Defocus

        // Should validate successfully on defocus when minimum met
        XCTAssertTrue(sut.cardNumberValid ?? false)
        XCTAssertEqual(sut.cardNumberError, "")
        XCTAssertTrue(mockSchemeValidator.hasMinimumDigitsCalled)
    }

    func testCardNumberValidation_OnRefocus_ClearsErrorAndRevalidatesOnNextInput() {
        // Setup: Field has error, user refocuses
        mockSchemeValidator.getCardSchemeFromBINResult = .visa
        mockSchemeValidator.isCardNumberValidResult = false
        mockSchemeValidator.isPossibleCreditCardNumberResult = false

        // Simulate field with error
        sut.setEditingTextField(focusedField: .cardNumber)
        sut.cardNumberText = "4111111111111112" // Invalid card
        sut.setEditingTextField(focusedField: .expiryDate) // Defocus to trigger validation

        // Verify error exists
        XCTAssertFalse(sut.cardNumberValid ?? true)
        XCTAssertFalse(sut.cardNumberError.isEmpty)

        // Refocus the field
        sut.setEditingTextField(focusedField: .cardNumber)

        // Error should be cleared on refocus
        XCTAssertNil(sut.cardNumberValid)
        XCTAssertEqual(sut.cardNumberError, "")

        // Now user types new digit - should revalidate
        mockSchemeValidator.isDigitCountInValidRangeResult = true
        mockSchemeValidator.isCardNumberValidResult = true
        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        sut.cardNumberText = "4111111111111111" // Valid card

        // Should validate with new input
        XCTAssertTrue(sut.cardNumberValid ?? false)
        XCTAssertEqual(sut.cardNumberError, "")
    }

    func testCardNumberValidation_UnknownScheme_UsesDefaultRange() {
        // Setup: Unknown scheme, should use 13-19 digit range
        mockSchemeValidator.getCardSchemeFromBINResult = nil
        mockSchemeValidator.digitRangeResult = (13, 19) // Default range
        mockSchemeValidator.isDigitCountInValidRangeResult = true // Within 13-19 range
        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        mockSchemeValidator.isUnknownCardNumberLengthValidResult = true

        sut.setEditingTextField(focusedField: .cardNumber)
        sut.cardNumberText = "1234567890121" // 13 digits, within default range

        // Should validate using default 13-19 range
        XCTAssertTrue(sut.cardNumberValid ?? false)
        XCTAssertEqual(sut.cardNumberError, "")
        XCTAssertTrue(mockSchemeValidator.isDigitCountInValidRangeCalled)
    }

    func testCardNumberValidation_UnknownScheme_DefocusShowsErrorBelowMinimum() {
        // Setup: Unknown scheme, below 13 digits
        mockSchemeValidator.getCardSchemeFromBINResult = nil
        mockSchemeValidator.digitRangeResult = (13, 19)
        mockSchemeValidator.hasMinimumDigitsResult = false // Below 13 digits

        sut.setEditingTextField(focusedField: .cardNumber)
        sut.cardNumberText = "1234567890" // 10 digits, below minimum
        sut.setEditingTextField(focusedField: nil) // Defocus

        // Should show error on defocus when below 13 digits
        XCTAssertFalse(sut.cardNumberValid ?? true)
        XCTAssertEqual(sut.cardNumberError, "Invalid card number")
        XCTAssertTrue(mockSchemeValidator.hasMinimumDigitsCalled)
    }

    // MARK: - Additional BDD Coverage Tests

    func testCardNumberValidation_DuringTyping_ClearsErrorWhenDeletingBelowMinimum() {
        // Setup: Card number has error (16 digits, invalid Luhn)
        mockSchemeValidator.getCardSchemeFromBINResult = .visa
        mockSchemeValidator.isDigitCountInValidRangeResult = true
        mockSchemeValidator.isPossibleCreditCardNumberResult = false
        mockSchemeValidator.isCardNumberValidResult = false

        sut.setEditingTextField(focusedField: .cardNumber)
        sut.cardNumberText = "4111111111111112" // Invalid, shows error

        XCTAssertFalse(sut.cardNumberValid ?? true)
        XCTAssertEqual(sut.cardNumberError, "Invalid card number")

        // User deletes to below minimum
        mockSchemeValidator.isDigitCountInValidRangeResult = false
        mockSchemeValidator.isPossibleCreditCardNumberCalled = false
        sut.cardNumberText = "411111111111" // 12 digits, below Visa minimum of 16

        // Error should be cleared when below minimum during typing
        XCTAssertNil(sut.cardNumberValid)
        XCTAssertEqual(sut.cardNumberError, "")
    }

    func testDeletingCardNumberWhileFocused_DisablesForm() {
        mockSchemeValidator.getCardSchemeFromBINResult = .visa
        mockSchemeValidator.isDigitCountInValidRangeResult = true
        mockSchemeValidator.isCardNumberValidResult = true

        sut.setEditingTextField(focusedField: .cardNumber)
        sut.cardNumberText = "4111111111111111"
        XCTAssertTrue(sut.cardNumberValid ?? false, "Card number should be valid initially")

        mockSchemeValidator.isDigitCountInValidRangeResult = false
        sut.cardNumberText = "411111111111111"

        XCTAssertNil(sut.cardNumberValid, "Deleting below valid range should clear cardNumberValid")
        XCTAssertEqual(sut.cardNumberError, "", "Error message should be cleared when below minimum during typing")
    }

    func testDeletingCardNumberWhileFocused_UnknownScheme_DisablesForm() {
        mockSchemeValidator.getCardSchemeFromBINResult = nil
        mockSchemeValidator.isDigitCountInValidRangeResult = true
        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        mockSchemeValidator.isUnknownCardNumberLengthValidResult = true

        sut.setEditingTextField(focusedField: .cardNumber)
        sut.cardNumberText = "1234567890123456"
        XCTAssertTrue(sut.cardNumberValid ?? false, "Card number should be valid initially (unknown scheme)")

        mockSchemeValidator.isDigitCountInValidRangeResult = false
        sut.cardNumberText = "123456789012345"

        XCTAssertNil(sut.cardNumberValid, "Deleting below valid range should clear cardNumberValid")
        XCTAssertEqual(sut.cardNumberError, "", "Error message should be cleared when below minimum during typing")
    }

    func testCardNumberClear_ResetsAllState() {
        // Setup: Valid card number entered
        mockSchemeValidator.getCardSchemeFromBINResult = .visa
        mockSchemeValidator.isPossibleCreditCardNumberResult = true
        mockSchemeValidator.isCardNumberValidResult = true
        mockSchemeValidator.isDigitCountInValidRangeResult = true

        sut.setEditingTextField(focusedField: .cardNumber)
        sut.cardNumberText = "4111111111111111"
        XCTAssertTrue(sut.cardNumberValid ?? false)

        // Clear the field
        mockSchemeValidator.getCardSchemeFromBINResult = nil
        mockSchemeValidator.isDigitCountInValidRangeResult = false
        sut.cardNumberText = ""

        // Should reset to neutral state
        XCTAssertNil(sut.cardNumberValid)
        XCTAssertEqual(sut.cardNumberError, "")
    }

    func testCardSchemeIcon_UpdatesWhenChangingScheme() {
        // Start with Visa
        mockSchemeValidator.getCardSchemeFromBINResult = .visa
        sut.cardNumberText = "4111"

        XCTAssertTrue(mockSchemeValidator.getCardSchemeFromBINCalled)
        XCTAssertEqual(sut.securityCodeTitle, "CVV")
        mockSchemeValidator.getCardSchemeFromBINCalled = false

        // Seed the default placeholder so switching to Amex flips it to the 4-digit sentinel.
        sut.securityCodePlaceholder = "XXX"

        // Change to Amex
        mockSchemeValidator.getCardSchemeFromBINResult = .amex
        sut.cardNumberText = "3782"

        XCTAssertTrue(mockSchemeValidator.getCardSchemeFromBINCalled)
        // The security-code title is a constant "CVV"; only the placeholder changes per scheme.
        XCTAssertEqual(sut.securityCodeTitle, "CVV")
        XCTAssertEqual(sut.securityCodePlaceholder, "XXXX")
    }

    func testCardNumber_EmptyField_NoErrorUntilInteraction() {
        // Initial state - no interaction
        XCTAssertNil(sut.cardNumberValid)
        XCTAssertEqual(sut.cardNumberError, "")

        // User focuses then immediately defocuses without typing
        sut.setEditingTextField(focusedField: .cardNumber)
        sut.setEditingTextField(focusedField: nil)

        // Should remain neutral (no error for empty untouched field)
        XCTAssertNil(sut.cardNumberValid)
        XCTAssertEqual(sut.cardNumberError, "")
    }

    func testCardNumber_EmptyAfterHavingInput_NoErrorOnDefocus() {
        // User enters some text first
        mockSchemeValidator.getCardSchemeFromBINResult = .visa
        mockSchemeValidator.isDigitCountInValidRangeResult = false

        sut.setEditingTextField(focusedField: .cardNumber)
        sut.cardNumberText = "4111"

        // User clears all text
        mockSchemeValidator.getCardSchemeFromBINResult = nil
        sut.cardNumberText = ""

        // Defocus - empty fields are not validated on defocus
        // (submit button handles required field validation)
        sut.setEditingTextField(focusedField: nil)

        // Empty field should remain neutral - no error shown
        XCTAssertNil(sut.cardNumberValid)
        XCTAssertEqual(sut.cardNumberError, "")
    }
}

// MARK: - Mock Classes

class MockCardSchemeValidator: CardSchemeValidator {
    override init(binDetector: CardSchemeDetector) {
        super.init(binDetector: binDetector)
    }

    convenience init() {
        self.init(binDetector: BinProcessing.makeCardSchemeDetector()!)
    }

    var isPossibleCreditCardNumberResult = false
    var isUnknownCardNumberLengthValidResult = false
    var isCardNumberValidResult = false
    var getCardSchemeFromBINResult: CardScheme?
    var digitRangeResult: (min: Int, max: Int) = (13, 19)
    var isDigitCountInValidRangeResult = false
    var hasMinimumDigitsResult = false

    var isPossibleCreditCardNumberCalled = false
    var isUnknownCardNumberLengthValidCalled = false
    var isCardNumberValidCalled = false
    var getCardSchemeFromBINCalled = false
    var digitRangeCalled = false
    var isDigitCountInValidRangeCalled = false
    var hasMinimumDigitsCalled = false

    var lastCardNumber: String?
    var lastSchemeForDigitRange: CardScheme?
    var lastNumberForDigitRange: String?

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

    override func digitRange(for scheme: CardScheme?) -> (min: Int, max: Int) {
        digitRangeCalled = true
        lastSchemeForDigitRange = scheme
        return digitRangeResult
    }

    override func isDigitCountInValidRange(number: String, scheme: CardScheme?) -> Bool {
        isDigitCountInValidRangeCalled = true
        lastNumberForDigitRange = number
        lastSchemeForDigitRange = scheme
        return isDigitCountInValidRangeResult
    }

    override func hasMinimumDigits(number: String, scheme: CardScheme?) -> Bool {
        hasMinimumDigitsCalled = true
        lastNumberForDigitRange = number
        lastSchemeForDigitRange = scheme
        return hasMinimumDigitsResult
    }
}

class MockCardExpiryDateValidator: CardExpiryDateValidatior {
    var validateCreditCardExpiryResult: ExpiryValidation = .valid
    var validateCreditCardExpiryCalled = false
    var lastStringDate: String?

    var validateMonthResult = true
    var validateMonthCalled = false
    var lastMonth: String?

    override func validateCreditCardExpiry(stringDate: String) -> ExpiryValidation {
        validateCreditCardExpiryCalled = true
        lastStringDate = stringDate
        return validateCreditCardExpiryResult
    }

    override func validateMonth(month: String) -> Bool {
        validateMonthCalled = true
        lastMonth = month
        return validateMonthResult
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

    var containsOnlyAllowedCharactersResult = true
    var containsOnlyAllowedCharactersCalled = false

    var startsWithLetterResult = true
    var startsWithLetterCalled = false

    override func isValidName(_ name: String) -> Bool {
        isValidNameCalled = true
        lastName = name
        return isValidNameResult
    }

    override func containsOnlyAllowedCharacters(_ name: String) -> Bool {
        containsOnlyAllowedCharactersCalled = true
        return containsOnlyAllowedCharactersResult
    }

    override func startsWithLetter(_ name: String) -> Bool {
        startsWithLetterCalled = true
        return startsWithLetterResult
    }
}

class MockCardDetailsFormatter: CardDetailsFormatter {
    var formatCardNumberResult = (formattedText: "", newCursorPosition: 0)
    var formatExpiryDateResult = (formattedText: "", newCursorPosition: 0)
    var formatSecurityCodeResult = (formattedText: "", newCursorPosition: 0)

    var formatCardNumberCallCount = 0
    var formatExpiryDateCallCount = 0
    var formatSecurityCodeCallCount = 0

    var lastCardNumberInput: (updatedText: String, cursorPosition: Int, maxDigits: Int, spacingPattern: CardSpacingPattern)?
    var lastExpiryDateInput: (updatedText: String, cursorPosition: Int)?
    var lastSecurityCodeInput: (updatedText: String, cursorPosition: Int, maxDigits: Int)?

    override func formatCardNumber(
        updatedText: String,
        cursorPosition: Int,
        maxDigits: Int,
        spacingPattern: CardSpacingPattern = .standard
    ) -> (formattedText: String, newCursorPosition: Int) {
        formatCardNumberCallCount += 1
        lastCardNumberInput = (
            updatedText: updatedText,
            cursorPosition: cursorPosition,
            maxDigits: maxDigits,
            spacingPattern: spacingPattern)
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
