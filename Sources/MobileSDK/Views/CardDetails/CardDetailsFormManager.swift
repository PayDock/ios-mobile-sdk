//
//  CardDetailsFormManager.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 22.08.2023..
//

import Foundation
import SwiftUI

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
            if !cardholderNameText.isEmpty {
                self.validateTextField(.cardholderName)
            }
        }
    }
    var cardNumberText: String = "" {
        didSet {
            self.updateCardIssuerIcon()
            self.updateSecurityCodeTitleAndPlaceholder()
            if !cardNumberText.isEmpty {
                self.validateTextField(.cardNumber)
            }
            if !securityCodeText.isEmpty {
                self.validateTextField(.securityCode)
            }
        }
    }
    var expiryDateText = "" {
        didSet {
            if !expiryDateText.isEmpty {
                self.validateTextField(.expiryDate)
            }
        }
    }
    var securityCodeText = "" {
        didSet {
            if !securityCodeText.isEmpty {
                self.validateTextField(.securityCode)
            }
        }
    }

    private var currentTextField: CardDetailsFocusable?

    // MARK: - Initialisation

    init(shouldValidateCardholderName: Bool = true,
         supportedSchemes: Set<CardScheme>? = nil,
         enableCardValidation: Bool = false,
         cardIssuerValidator: CardSchemeValidator = CardSchemeValidator(),
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

    func setEditingTextField(focusedField: CardDetailsFocusable?) {
        currentTextField = focusedField

        guard let focusedField = focusedField else { return }

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

        case .mastercard, .solo, .ausbc:
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
        case .ausbc: return Image("australian-commonwealth-bank", bundle: Bundle.module)
        case .diners: return Image("diners", bundle: Bundle.module)
        case .discover: return Image("discover", bundle: Bundle.module)
        case .japcb: return Image("jcb", bundle: Bundle.module)
        case .mastercard: return Image("mastercard", bundle: Bundle.module)
        case .visa: return Image("visa", bundle: Bundle.module)
        case .solo: return Image("solo", bundle: Bundle.module)
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
        if cardSchemeValidator.isPossibleCreditCardNumber(number: cardholderNameText) {
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

    // MARK: - Validate card number

    private func validateCardNumber() {
        // if card scheme is detected, base validation on the scheme
        if let scheme = cardSchemeValidator.getCardSchemeFromBIN(cardNumber: cardNumberText),
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
                let isLuhnValid = cardSchemeValidator.isPossibleCreditCardNumber(number: cardNumberText)
                let scheme = cardSchemeValidator.getCardSchemeFromBIN(cardNumber: cardNumberText)
                let errorMessage = (isLuhnValid && scheme == nil) ? "Card type not accepted" : "Invalid card number"
                updateCardNumberValidationState(isValid: false, errorMessage: errorMessage)
            } else {
                // Use generic validation if the scheme was not detected
                validateCardNumberForUnknownScheme()
            }
        }
    }

    private func validateCardNumberForUnknownScheme() {
        guard cardSchemeValidator.isPossibleCreditCardNumber(number: cardNumberText),
              cardSchemeValidator.isUnknownCardNumberLengthValid(number: cardNumberText) else {
            updateCardNumberValidationState(isValid: false, errorMessage: "Invalid card number")
            return
        }

        // If all validations pass, clear any errors
        updateCardNumberValidationState(isValid: true, errorMessage: nil)
    }

    private func validateAgainstSupportedSchemes(detectedScheme: CardScheme) {
        // Validate against supported schemes if provided
        guard let supportedSchemes = supportedSchemes, supportedSchemes.contains(detectedScheme) else {
            updateCardNumberValidationState(isValid: false, errorMessage: "Card type not accepted")
            return
        }

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
        } else {
            securityCodeValid = false
            securityCodeError = "Invalid security code"
        }
    }

    private func validateSecurityCodeForNoScheme() {
        if cardSecurityCodeValidator.isSecurityCodeValidForUnknownScheme(code: securityCodeText) {
            securityCodeValid = true
            securityCodeError = ""
        } else {
            securityCodeValid = false
            securityCodeError = "Invalid security code"
        }
    }

    func isFormValid() -> Bool {
        let cardHolderNameValid = shouldValidateCardholderName
            ? (!cardholderNameText.isEmpty && !cardSchemeValidator.isPossibleCreditCardNumber(number: cardholderNameText))
            : true
        let creditCardValid = enableCardValidation
            ? cardSchemeValidator.isCardNumberValid(number: cardNumberText)
            : cardSchemeValidator.isPossibleCreditCardNumber(number: cardNumberText)
        let expiryValidation = cardExpiryDateValidator.validateCreditCardExpiry(stringDate: expiryDateText) == .valid

        let securityCodeValidation: Bool
        if let cardScheme =  cardSchemeValidator.getCardSchemeFromBIN(cardNumber: cardNumberText), enableCardValidation {
            securityCodeValidation = cardSecurityCodeValidator.isSecurityCodeValid(
                code: securityCodeText,
                cardScheme: cardScheme ?? .visa) // Default to 3 digit CVV validation
        } else {
            securityCodeValidation = cardSecurityCodeValidator.isSecurityCodeValidForUnknownScheme(code: securityCodeText)
        }

        return cardHolderNameValid && creditCardValid && expiryValidation && securityCodeValidation
    }

    // MARK: - Formatting

    func formatCardNumber(updatedText: String, cursorPosition: Int) -> Int {
        let result = cardDetailsFormatter.formatCardNumber(updatedText: updatedText, cursorPosition: cursorPosition)
        cardNumberText = result.formattedText
        return result.newCursorPosition
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
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        editingCardholderName = false
        editingCardNumber = false
        editingExpiryDate = false
        editingSecurityCode = false
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
