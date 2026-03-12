//
//  CardDetailsFormManager.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 22.08.2023..
//

// swiftlint:disable file_length

import Foundation
import SwiftUI
import BinProcessing

// swiftlint:disable:next type_body_length
class CardDetailsFormManager: ObservableObject {

    // MARK: - Dependencies

    private let shouldValidateCardholderName: Bool
    private let supportedSchemes: Set<CardScheme>?
    private let enableCardValidation: Bool
    private let cardSchemeValidator: CardSchemeValidator
    private let cardExpiryDateValidator: CardExpiryDateValidatior
    private let cardSecurityCodeValidator: CardSecurityCodeValidator
    private let cardDetailsFormatter: CardDetailsFormatter
    private let cardNameValidator: CardNameValidator

    // MARK: - Properties

    @Published var cardholderNameError = ""
    @Published var cardNumberError = ""
    @Published var expiryDateError = ""
    @Published var securityCodeError = ""

    @Published var editingCardholderName = false
    @Published var editingCardNumber = false
    @Published var editingExpiryDate = false
    @Published var editingSecurityCode = false

    @Published var cardHolderNameValid: Bool?
    @Published var cardNumberValid: Bool?
    @Published var expiryDateValid: Bool?
    @Published var securityCodeValid: Bool?

    @Published var cardImage: Image? = Image("credit-card", bundle: Bundle.module)

    let cardholderNameTitle = "Cardholder name"
    let cardNumberTitle = "Card number"
    let expiryDateTitle = "Expiry"
    @Published var securityCodeTitle = "CVV"

    var cardholderNamePlaceholder = ""
    var cardNumberPlaceholder = "XXXX XXXX XXXX XXXX"
    var expiryDatePlaceholder = "MM/YY"
    @Published var securityCodePlaceholder = "XXX"

    var cardholderNameText: String = "" {
        didSet {
            if cardholderNameText.isEmpty {
                // Clear error and reset input tracking when all text is deleted
                cardholderNameHadInput = false
                if isCardholderNameBeingEdited {
                    cardHolderNameValid = nil
                    cardholderNameError = ""
                }
            } else {
                cardholderNameHadInput = true
                // Perform active validation during typing
                if isCardholderNameBeingEdited {
                    validateCardholderNameDuringTyping()
                }
            }
        }
    }
    var cardNumberText: String = "" {
        didSet {
            self.updateCardIssuerIcon()
            self.updateSecurityCodeTitleAndPlaceholder()
            if cardNumberText.isEmpty {
                // Clear error and reset tracking when all text is deleted
                cardNumberWasInErrorState = false
                if isCardNumberBeingEdited {
                    cardNumberValid = nil
                    cardNumberError = ""
                }
            } else {
                // If field was refocused with error, clear the error state flag on first input
                if cardNumberWasInErrorState {
                    cardNumberWasInErrorState = false
                }
                self.validateTextField(.cardNumber)
            }
            // Re-validate security code when card number changes (scheme may change CVV requirements)
            if !securityCodeText.isEmpty && !isSecurityCodeBeingEdited {
                self.validateSecurityCode()
            }
        }
    }
    var expiryDateText = "" {
        didSet {
            if expiryDateText.isEmpty {
                expiryDateHadInput = false
                if isExpiryDateBeingEdited {
                    expiryDateValid = nil
                    expiryDateError = ""
                }
            } else {
                expiryDateHadInput = true
                // Active validation during typing at specific digit counts
                if isExpiryDateBeingEdited {
                    validateExpiryDuringTyping(oldValue: oldValue)
                }
            }
        }
    }
    var securityCodeText = "" {
        didSet {
            if securityCodeText.isEmpty {
                // Clear error and reset input tracking when all text is deleted
                securityCodeHadInput = false
                securityCodeHadErrorOnDefocus = false
                if isSecurityCodeBeingEdited {
                    securityCodeValid = nil
                    securityCodeError = ""
                }
            } else {
                securityCodeHadInput = true
                // Active validation only if field was previously defocused with error
                if securityCodeHadErrorOnDefocus && isSecurityCodeBeingEdited {
                    self.validateTextField(.securityCode)
                }
            }
        }
    }

    private var currentTextField: CardDetailsFocusable?

    /// Tracks if fields are being actively edited
    private var isCardholderNameBeingEdited = false
    private var isCardNumberBeingEdited = false
    private var isExpiryDateBeingEdited = false
    private var isSecurityCodeBeingEdited = false

    /// Tracks if fields were in an error state when refocused
    private var cardholderNameWasInErrorState = false
    private var cardNumberWasInErrorState = false
    private var expiryDateWasInErrorState = false
    private var securityCodeWasInErrorState = false

    /// Tracks if fields have had data entered (to avoid validating empty fields on defocus)
    private var cardholderNameHadInput = false
    private var expiryDateHadInput = false
    private var securityCodeHadInput = false

    /// Tracks if security code has been defocused with error (enables active validation on refocus)
    private var securityCodeHadErrorOnDefocus = false

    // MARK: - Initialisation

    init(shouldValidateCardholderName: Bool = true,
         supportedSchemes: Set<CardScheme>? = nil,
         enableCardValidation: Bool = false,
         cardIssuerValidator: CardSchemeValidator = CardSchemeValidator(binDetector: BinProcessing.makeCardSchemeDetector()!),
         cardExpiryDateValidator: CardExpiryDateValidatior = CardExpiryDateValidatior(),
         cardSecurityCodeValidator: CardSecurityCodeValidator = CardSecurityCodeValidator(),
         cardExpiryDateFormatter: CardDetailsFormatter = CardDetailsFormatter(),
         cardNameValidator: CardNameValidator = CardNameValidator()) {
        self.shouldValidateCardholderName = shouldValidateCardholderName
        self.supportedSchemes = supportedSchemes
        self.enableCardValidation = enableCardValidation && (supportedSchemes != nil && !(supportedSchemes?.isEmpty ?? true))
        self.cardSchemeValidator = cardIssuerValidator
        self.cardExpiryDateValidator = cardExpiryDateValidator
        self.cardSecurityCodeValidator = cardSecurityCodeValidator
        self.cardDetailsFormatter = cardExpiryDateFormatter
        self.cardNameValidator = cardNameValidator
    }

    // MARK: - Methods

    // swiftlint:disable:next function_body_length
    func setEditingTextField(focusedField: CardDetailsFocusable?) {
        // Track which fields were being edited before focus change
        let wasEditingCardholderName = editingCardholderName
        let wasEditingCardNumber = editingCardNumber
        let wasEditingExpiryDate = editingExpiryDate
        let wasEditingSecurityCode = editingSecurityCode

        currentTextField = focusedField

        guard let focusedField = focusedField else {
            // All fields defocused - validate all that had input
            editingCardholderName = false
            editingCardNumber = false
            editingExpiryDate = false
            editingSecurityCode = false
            isCardholderNameBeingEdited = false
            isCardNumberBeingEdited = false
            isExpiryDateBeingEdited = false
            isSecurityCodeBeingEdited = false

            if wasEditingCardholderName { validateCardholderNameOnDefocus() }
            if wasEditingCardNumber { validateCardNumberOnDefocus() }
            if wasEditingExpiryDate { validateExpiryDateOnDefocus() }
            if wasEditingSecurityCode { validateSecurityCodeOnDefocus() }
            return
        }

        // Handle field defocus (switching to another field)
        if wasEditingCardholderName && focusedField != .cardholderName {
            isCardholderNameBeingEdited = false
            validateCardholderNameOnDefocus()
        }
        if wasEditingCardNumber && focusedField != .cardNumber {
            isCardNumberBeingEdited = false
            validateCardNumberOnDefocus()
        }
        if wasEditingExpiryDate && focusedField != .expiryDate {
            isExpiryDateBeingEdited = false
            validateExpiryDateOnDefocus()
        }
        if wasEditingSecurityCode && focusedField != .securityCode {
            isSecurityCodeBeingEdited = false
            validateSecurityCodeOnDefocus()
        }

        // Handle field focus/refocus
        switch focusedField {
        case .cardholderName:
            cardholderNameWasInErrorState = !cardholderNameError.isEmpty
            isCardholderNameBeingEdited = true
            if cardholderNameWasInErrorState {
                cardHolderNameValid = nil
                cardholderNameError = ""
            }

        case .cardNumber:
            cardNumberWasInErrorState = !cardNumberError.isEmpty
            isCardNumberBeingEdited = true
            if cardNumberWasInErrorState {
                cardNumberValid = nil
                cardNumberError = ""
            }

        case .expiryDate:
            expiryDateWasInErrorState = !expiryDateError.isEmpty
            isExpiryDateBeingEdited = true
            if expiryDateWasInErrorState {
                expiryDateValid = nil
                expiryDateError = ""
            }

        case .securityCode:
            securityCodeWasInErrorState = !securityCodeError.isEmpty
            isSecurityCodeBeingEdited = true
            if securityCodeWasInErrorState {
                securityCodeValid = nil
                securityCodeError = ""
            }
        }

        // Reset editing flags for non-focused fields
        isCardholderNameBeingEdited = focusedField == .cardholderName
        isCardNumberBeingEdited = focusedField == .cardNumber
        isExpiryDateBeingEdited = focusedField == .expiryDate
        isSecurityCodeBeingEdited = focusedField == .securityCode

        editingCardholderName = focusedField == .cardholderName
        editingCardNumber = focusedField == .cardNumber
        editingExpiryDate = focusedField == .expiryDate
        editingSecurityCode = focusedField == .securityCode
    }

    func updateCardIssuerIcon() {
        let cardScheme = cardSchemeValidator.getCardSchemeFromBIN(cardNumber: cardNumberText)
        cardImage = getCardSchemeIcon(for: cardScheme)
    }

    func updateSecurityCodeTitleAndPlaceholder() {
        let cardScheme = cardSchemeValidator.getCardSchemeFromBIN(cardNumber: cardNumberText)

        switch cardScheme {
        case .visa, .diners, .japcb:
            securityCodeTitle = "CVV"
            securityCodePlaceholder = "XXX"

        case .mastercard:
            securityCodeTitle = "CVC"
            securityCodePlaceholder = "XXX"

        case .amex:
            securityCodeTitle = "CID"
            securityCodePlaceholder = "XXXX"

        case .discover:
            securityCodeTitle = "CID"
            securityCodePlaceholder = "XXX"

        case .unionpay:
            securityCodeTitle = "CVN"
            securityCodePlaceholder = "XXX"

        case .none:
            securityCodeTitle = "CVV"
            securityCodePlaceholder = "XXX"
        }
    }

    private func getCardSchemeIcon(for cardScheme: CardScheme?) -> Image {
        switch cardScheme {
        case .amex: return Image("american-express", bundle: Bundle.module)
        case .diners: return Image("diners", bundle: Bundle.module)
        case .discover: return Image("discover", bundle: Bundle.module)
        case .japcb: return Image("jcb", bundle: Bundle.module)
        case .mastercard: return Image("mastercard", bundle: Bundle.module)
        case .visa: return Image("visa", bundle: Bundle.module)
        case .unionpay: return Image("unionpay", bundle: Bundle.module)
        case .none: return Image("credit-card", bundle: Bundle.module)
        }
    }

    // MARK: - Validations

    private func validateTextField(_ textField: CardDetailsFocusable?) {
        guard let textField = textField else { return }

        switch textField {
        case .cardholderName: if shouldValidateCardholderName { validateCardholderName() }
        case .cardNumber: validateCardNumber()
        case .expiryDate: validateExpiryDate()
        case .securityCode: validateSecurityCode()
        }
    }

    private func validateCardholderName() {
        // Only check for card number if 12+ digits entered (minimum for valid card numbers)
        let digitCount = cardholderNameText.filter { $0.isNumber }.count
        if digitCount >= 12 && cardSchemeValidator.isPossibleCreditCardNumber(number: cardholderNameText) {
            cardHolderNameValid = false
            cardholderNameError = "Card number is in the wrong field!"

        } else if !cardholderNameText.isEmpty && cardNameValidator.isValidName(cardholderNameText) {
            cardHolderNameValid = true
            cardholderNameError = ""

        } else {
            cardHolderNameValid = false
            cardholderNameError = "Invalid name"
        }
    }

    /// Validates cardholder name on defocus
    private func validateCardholderNameOnDefocus() {
        guard shouldValidateCardholderName && cardholderNameHadInput else { return }
        validateCardholderName()
    }

    /// Validates cardholder name during typing - checks for immediate errors
    private func validateCardholderNameDuringTyping() {
        guard shouldValidateCardholderName else { return }

        // Check if user entered a credit card number in the name field (only after 12+ digits)
        let digitCount = cardholderNameText.filter { $0.isNumber }.count
        if digitCount >= 12 && cardSchemeValidator.isPossibleCreditCardNumber(number: cardholderNameText) {
            cardHolderNameValid = false
            cardholderNameError = "Card number is in the wrong field!"
            return
        }

        // Check for invalid characters
        if !cardNameValidator.containsOnlyAllowedCharacters(cardholderNameText) {
            cardHolderNameValid = false
            cardholderNameError = "Invalid name"
            return
        }

        // Check if name starts with a letter
        if !cardNameValidator.startsWithLetter(cardholderNameText) {
            cardHolderNameValid = false
            cardholderNameError = "Invalid name"
            return
        }

        // If previously in error state, check if now valid
        if cardHolderNameValid == false {
            if cardNameValidator.isValidName(cardholderNameText) {
                cardHolderNameValid = true
                cardholderNameError = ""
            } else {
                // Keep checking - clear error if basic checks pass (full validation on defocus)
                cardHolderNameValid = nil
                cardholderNameError = ""
            }
        }
    }

    // MARK: - Validate card number

    private func validateCardNumber() {
        // During typing: only validate if digit count is within valid range for scheme
        // This prevents false positives from Luhn check on incomplete card numbers
        let scheme = cardSchemeValidator.getCardSchemeFromBIN(cardNumber: cardNumberText)

        // Check if digit count is within valid range for the detected scheme
        let isInValidRange = cardSchemeValidator.isDigitCountInValidRange(number: cardNumberText, scheme: scheme)

        // Priority check: Show "card type not accepted" early if unsupported scheme is detected
        if handleUnsupportedSchemeIfDetected(scheme: scheme) { return }

        // During typing: only run Luhn check if digit count is in valid range
        if isCardNumberBeingEdited && !isInValidRange {
            // Clear validation when digit count falls below minimum (e.g., when deleting)
            // Ensures action button disables when form becomes invalid
            cardNumberValid = nil
            cardNumberError = ""
            return
        }

        // if card scheme is detected, base validation on the scheme
        if let scheme = scheme,
           cardSchemeValidator.isCardNumberValid(number: cardNumberText) {
            if enableCardValidation {
                validateAgainstSupportedSchemes(detectedScheme: scheme)
            } else {
                updateCardNumberValidationState(isValid: true, errorMessage: nil)
            }

        // if no card scheme is detected, base validation on default values if allowed
        } else {
            if enableCardValidation {
                // Only supported schemes are allowed, detect the reason of failure
                // Only run Luhn check if digit count is in valid range
                let isLuhnValid = isInValidRange ? cardSchemeValidator.isPossibleCreditCardNumber(number: cardNumberText) : false
                let errorMessage = (isLuhnValid && scheme == nil) ? "Card type not accepted" : "Invalid card number"
                updateCardNumberValidationState(isValid: false, errorMessage: errorMessage)
            } else {
                // Use generic validation if the scheme was not detected
                validateCardNumberForUnknownScheme()
            }
        }
    }

    private func validateCardNumberForUnknownScheme() {
        // During typing: only validate if digit count is within valid range (12-19)
        let isInValidRange = cardSchemeValidator.isDigitCountInValidRange(number: cardNumberText, scheme: nil)

        if isCardNumberBeingEdited && !isInValidRange {
            // Clear validation when digit count falls below minimum (e.g., when deleting)
            // Ensures action button disables when form becomes invalid
            cardNumberValid = nil
            cardNumberError = ""
            return
        }

        guard cardSchemeValidator.isPossibleCreditCardNumber(number: cardNumberText),
              cardSchemeValidator.isUnknownCardNumberLengthValid(number: cardNumberText) else {
            updateCardNumberValidationState(isValid: false, errorMessage: "Invalid card number")
            return
        }

        // If all validations pass, clear any errors
        updateCardNumberValidationState(isValid: true, errorMessage: nil)
    }

    /// Checks if an unsupported card scheme is detected early (with > 8 digits for BIN detection).
    /// If detected, updates validation state with error and returns true so caller can exit early.
    /// - Parameter scheme: The detected card scheme from BIN lookup, or nil if not detected
    /// - Returns: true if an unsupported scheme was detected and handled, false otherwise
    private func handleUnsupportedSchemeIfDetected(scheme: CardScheme?) -> Bool {
        guard enableCardValidation else { return false }

        let digitCount = cardNumberText.filter { $0.isNumber }.count
        if digitCount > 8, let detectedScheme = scheme,
           let supportedSchemes = supportedSchemes, !supportedSchemes.contains(detectedScheme) {
            updateCardNumberValidationState(isValid: false, errorMessage: "Card type not accepted")
            return true
        }
        return false
    }

    private func validateAgainstSupportedSchemes(detectedScheme: CardScheme) {
        // Validate against supported schemes if provided
        guard let supportedSchemes = supportedSchemes, supportedSchemes.contains(detectedScheme) else {
            updateCardNumberValidationState(isValid: false, errorMessage: "Card type not accepted")
            return
        }

        updateCardNumberValidationState(isValid: true, errorMessage: nil)
    }

    /// Validates card number on defocus (when user leaves the field)
    /// This performs full validation including minimum digit check
    private func validateCardNumberOnDefocus() {
        // Don't validate empty fields - submit button handles required field validation
        guard !cardNumberText.isEmpty else { return }

        let scheme = cardSchemeValidator.getCardSchemeFromBIN(cardNumber: cardNumberText)

        // Priority check: Show "card type not accepted" early if unsupported scheme is detected
        if handleUnsupportedSchemeIfDetected(scheme: scheme) { return }

        // Check minimum digits first - show error if not met
        if !cardSchemeValidator.hasMinimumDigits(number: cardNumberText, scheme: scheme) {
            updateCardNumberValidationState(isValid: false, errorMessage: "Invalid card number")
            return
        }

        // If card scheme is detected, base validation on the scheme
        if let scheme = scheme,
           cardSchemeValidator.isCardNumberValid(number: cardNumberText) {
            if enableCardValidation {
                validateAgainstSupportedSchemes(detectedScheme: scheme)
            } else {
                updateCardNumberValidationState(isValid: true, errorMessage: nil)
            }
        } else {
            // No scheme detected or validation failed
            if enableCardValidation {
                // Only supported schemes are allowed, detect the reason of failure
                let isLuhnValid = cardSchemeValidator.isPossibleCreditCardNumber(number: cardNumberText)
                let errorMessage = (isLuhnValid && scheme == nil) ? "Card type not accepted" : "Invalid card number"
                updateCardNumberValidationState(isValid: false, errorMessage: errorMessage)
            } else {
                // Use generic validation if the scheme was not detected
                validateCardNumberForUnknownSchemeOnDefocus()
            }
        }
    }

    /// Validates unknown scheme card number on defocus
    private func validateCardNumberForUnknownSchemeOnDefocus() {
        // Check minimum digits (12 for unknown schemes)
        if !cardSchemeValidator.hasMinimumDigits(number: cardNumberText, scheme: nil) {
            updateCardNumberValidationState(isValid: false, errorMessage: "Invalid card number")
            return
        }

        guard cardSchemeValidator.isPossibleCreditCardNumber(number: cardNumberText),
              cardSchemeValidator.isUnknownCardNumberLengthValid(number: cardNumberText) else {
            updateCardNumberValidationState(isValid: false, errorMessage: "Invalid card number")
            return
        }

        // If all validations pass, clear any errors
        updateCardNumberValidationState(isValid: true, errorMessage: nil)
    }

    private func updateCardNumberValidationState(isValid: Bool, errorMessage: String?) {
        cardNumberValid = isValid
        cardNumberError = errorMessage ?? ""
    }

    // MARK: - Validate expiry date

    private func validateExpiryDate() {
        let expiryValidation = cardExpiryDateValidator.validateCreditCardExpiry(stringDate: expiryDateText)
        switch expiryValidation {
        case .valid:
            expiryDateValid = true
            expiryDateError = ""

        case .expired:
            expiryDateValid = false
            expiryDateError = "Card expired"

        case .invalidInput:
            expiryDateValid = false
            expiryDateError = "Invalid expiry date"
        }
    }

    /// Validates expiry date on defocus
    private func validateExpiryDateOnDefocus() {
        guard expiryDateHadInput else { return }
        validateExpiryDate()
    }

    /// Validates expiry during typing at specific digit counts (2nd for month, 4th for full date)
    private func validateExpiryDuringTyping(oldValue: String) {
        let currentDigitCount = cardExpiryDateValidator.digitCount(from: expiryDateText)
        let previousDigitCount = cardExpiryDateValidator.digitCount(from: oldValue)

        // Clear validation if user deletes all input
        if expiryDateText.isEmpty {
            expiryDateValid = nil
            expiryDateError = ""
            return
        }

        // Detect if user is deleting/editing (digit count decreased or same but text changed)
        let isDeleting = currentDigitCount < previousDigitCount
        let isEditing = currentDigitCount == previousDigitCount && expiryDateText != oldValue

        // If deleting and going below a validation threshold, clear error and re-validate if at threshold
        if isDeleting || isEditing {
            // Clear error when deleting below thresholds
            if currentDigitCount < 2 {
                expiryDateValid = nil
                expiryDateError = ""
                return
            }

            // Re-validate at current digit count
            if currentDigitCount >= 2 {
                validateExpiryMonth()
            }
            if currentDigitCount >= 4 {
                validateExpiryDate()
            }
            return
        }

        // Validate month when 2nd digit is entered
        if currentDigitCount == 2 && previousDigitCount < 2 {
            validateExpiryMonth()
        }

        // Validate full date when 4th digit is entered
        if currentDigitCount >= 4 && previousDigitCount < 4 {
            validateExpiryDate()
        }
    }

    /// Validates just the month portion of the expiry date
    private func validateExpiryMonth() {
        guard let month = cardExpiryDateValidator.extractMonth(from: expiryDateText) else {
            return
        }

        if !cardExpiryDateValidator.validateMonth(month: month) {
            expiryDateValid = false
            expiryDateError = "Invalid month"
        } else {
            // Month is valid, clear any expiry error (including "Card expired" from previous full validation)
            // Full date validation will run again when 4 digits are entered
            if !expiryDateError.isEmpty {
                expiryDateValid = nil
                expiryDateError = ""
            }
        }
    }

    // MARK: - Validate security code

    private func validateSecurityCode() {
        if let cardScheme = cardSchemeValidator.getCardSchemeFromBIN(cardNumber: cardNumberText) {
            validateSecurityCodeForDetectedScheme(scheme: cardScheme)
        } else {
            validateSecurityCodeForNoScheme()
        }
    }

    private func validateSecurityCodeForDetectedScheme(scheme: CardScheme) {
        if cardSecurityCodeValidator.isSecurityCodeValid(code: securityCodeText, cardScheme: scheme) {
            securityCodeValid = true
            securityCodeError = ""
            securityCodeHadErrorOnDefocus = false
        } else {
            securityCodeValid = false
            securityCodeError = "Invalid security code"
        }
    }

    private func validateSecurityCodeForNoScheme() {
        if cardSecurityCodeValidator.isSecurityCodeValidForUnknownScheme(code: securityCodeText) {
            securityCodeValid = true
            securityCodeError = ""
            securityCodeHadErrorOnDefocus = false
        } else {
            securityCodeValid = false
            securityCodeError = "Invalid security code"
        }
    }

    /// Validates security code on defocus
    private func validateSecurityCodeOnDefocus() {
        guard securityCodeHadInput else { return }
        validateSecurityCode()
        // Track if error shown on defocus to enable active validation on refocus
        if securityCodeValid == false {
            securityCodeHadErrorOnDefocus = true
        }
    }

    func isFormValid() -> Bool {
        let cardHolderNameValid = shouldValidateCardholderName
            ? (!cardholderNameText.isEmpty && !cardSchemeValidator.isPossibleCreditCardNumber(number: cardholderNameText))
            : true
        // When scheme validation is enabled, require cardNumberValid so that "Card type not accepted" blocks submit
        let creditCardValid = enableCardValidation
            ? (cardNumberValid == true)
            : cardSchemeValidator.isPossibleCreditCardNumber(number: cardNumberText)
        let expiryValidation = cardExpiryDateValidator.validateCreditCardExpiry(stringDate: expiryDateText) == .valid

        let securityCodeValidation: Bool
        if let cardScheme =  cardSchemeValidator.getCardSchemeFromBIN(cardNumber: cardNumberText), enableCardValidation {
            securityCodeValidation = cardSecurityCodeValidator.isSecurityCodeValid(
                code: securityCodeText,
                cardScheme: cardScheme)
        } else {
            securityCodeValidation = cardSecurityCodeValidator.isSecurityCodeValidForUnknownScheme(code: securityCodeText)
        }

        return cardHolderNameValid && creditCardValid && expiryValidation && securityCodeValidation
    }

    // MARK: - Formatting

    func formatCardNumber(updatedText: String, cursorPosition: Int) -> Int {
        let scheme = cardSchemeValidator.getCardSchemeFromBIN(cardNumber: updatedText)
        let maxDigits = cardSchemeValidator.digitRange(for: scheme).max
        let spacingPattern = cardSpacingPattern(for: scheme)
        let result = cardDetailsFormatter.formatCardNumber(
            updatedText: updatedText,
            cursorPosition: cursorPosition,
            maxDigits: maxDigits,
            spacingPattern: spacingPattern)
        cardNumberText = result.formattedText
        return result.newCursorPosition
    }

    private func cardSpacingPattern(for scheme: CardScheme?) -> CardDetailsFormatter.CardSpacingPattern {
        switch scheme {
        case .amex: return .amex
        case .diners: return .diners
        default: return .standard
        }
    }

    func formatExpiryDate(updatedText: String, cursorPosition: Int) -> Int {
        let result = cardDetailsFormatter.formatExpiryDate(updatedText: updatedText, cursorPosition: cursorPosition)
        expiryDateText = result.formattedText
        return result.newCursorPosition
    }

    func formatSecurityCode(updatedText: String, cursorPosition: Int) -> Int {
        let maxDigits: Int
        if let cardScheme = cardSchemeValidator.getCardSchemeFromBIN(cardNumber: cardNumberText) {
            maxDigits = cardSecurityCodeValidator.requiredDigits(cardScheme: cardScheme)
        } else {
            // When validation is disabled or card not detected, allow up to 4 digits
            maxDigits = 4
        }

        let result = cardDetailsFormatter.formatSecurityCode(updatedText: updatedText, cursorPosition: cursorPosition, maxDigits: maxDigits)
        securityCodeText = result.formattedText
        return result.newCursorPosition
    }

    // MARK: - Editing

    func endEditing() {
        // Validate fields on defocus if they were being edited
        if editingCardholderName { validateCardholderNameOnDefocus() }
        if editingCardNumber { validateCardNumberOnDefocus() }
        if editingExpiryDate { validateExpiryDateOnDefocus() }
        if editingSecurityCode { validateSecurityCodeOnDefocus() }

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        editingCardholderName = false
        editingCardNumber = false
        editingExpiryDate = false
        editingSecurityCode = false
        isCardholderNameBeingEdited = false
        isCardNumberBeingEdited = false
        isExpiryDateBeingEdited = false
        isSecurityCodeBeingEdited = false
    }
}

extension CardDetailsFormManager {

    enum CardDetailsFocusable: Hashable {
        case cardholderName
        case cardNumber
        case expiryDate
        case securityCode
    }
}
