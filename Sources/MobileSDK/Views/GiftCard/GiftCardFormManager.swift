//
//  GiftCardFormManager.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

class GiftCardFormManager: ObservableObject {

    private let cardDetailsFormatter: CardDetailsFormatter

    @Published var cardNumberError = ""
    @Published var pinError = ""

    @Published var editingCardNumber = false
    @Published var editingPin = false

    @Published var cardNumberValid: Bool?
    @Published var pinValid: Bool?

    let cardNumberTitle = "Card number"
    let pinTitle = "PIN"

    var numberOfValidationFailures: Int = 0
    var firstFieldWithError: GiftCardFocusable?

    private static let giftCardNumberMinDigits = 14
    private static let giftCardNumberMaxDigits = 25
    private static let pinDigitCount = 4

    var cardNumberText: String = "" {
        didSet {
            if cardNumberText.isEmpty {
                cardNumberWasInErrorState = false
                if isCardNumberBeingEdited {
                    cardNumberValid = nil
                    cardNumberError = ""
                }
            } else {
                if cardNumberWasInErrorState {
                    cardNumberWasInErrorState = false
                }
                validateTextField(.cardNumber)
            }
        }
    }
    var pinText = "" {
        didSet {
            if pinText.isEmpty {
                pinHadInput = false
                if isPinBeingEdited {
                    pinValid = nil
                    pinError = ""
                }
            } else {
                pinHadInput = true
                validateTextField(.pin)
            }
        }
    }

    private var currentTextField: GiftCardFocusable?

    /// Tracks if fields are being actively edited
    private var isCardNumberBeingEdited = false
    private var isPinBeingEdited = false

    /// Tracks if fields were in an error state when refocused
    private var cardNumberWasInErrorState = false
    private var pinWasInErrorState = false

    /// Tracks if PIN has had data entered (to avoid validating empty field on defocus)
    private var pinHadInput = false

    // MARK: - Initialisation

    init(cardDetailsFormatter: CardDetailsFormatter = CardDetailsFormatter()) {
        self.cardDetailsFormatter = cardDetailsFormatter
    }

    // MARK: - Methods

    func setEditingTextField(focusedField: GiftCardFocusable?) {
        let wasEditingCardNumber = editingCardNumber
        let wasEditingPin = editingPin

        currentTextField = focusedField

        guard let focusedField = focusedField else {
            editingCardNumber = false
            editingPin = false
            isCardNumberBeingEdited = false
            isPinBeingEdited = false

            if wasEditingCardNumber { validateCardNumberOnDefocus() }
            if wasEditingPin { validatePinOnDefocus() }
            return
        }

        if wasEditingCardNumber && focusedField != .cardNumber {
            isCardNumberBeingEdited = false
            validateCardNumberOnDefocus()
        }
        if wasEditingPin && focusedField != .pin {
            isPinBeingEdited = false
            validatePinOnDefocus()
        }

        switch focusedField {
        case .cardNumber:
            cardNumberWasInErrorState = !cardNumberError.isEmpty
            if cardNumberWasInErrorState {
                cardNumberValid = nil
                cardNumberError = ""
            }

        case .pin:
            pinWasInErrorState = !pinError.isEmpty
            if pinWasInErrorState {
                pinValid = nil
                pinError = ""
            }
        }

        isCardNumberBeingEdited = focusedField == .cardNumber
        isPinBeingEdited = focusedField == .pin
        editingCardNumber = focusedField == .cardNumber
        editingPin = focusedField == .pin
    }

    // MARK: - Validations

    private func validateTextField(_ textField: GiftCardFocusable?) {
        guard let textField = textField else { return }

        switch textField {
        case .cardNumber: validateCardNumber()
        case .pin: validatePin()
        }
    }

    private func validateCardNumber() {
        let digitCount = cardNumberText.filter { $0.isNumber }.count
        let isInValidRange = digitCount >= Self.giftCardNumberMinDigits && digitCount <= Self.giftCardNumberMaxDigits

        if isCardNumberBeingEdited && !isInValidRange {
            cardNumberValid = nil
            cardNumberError = ""
            return
        }

        if isInValidRange {
            updateCardNumberValidationState(isValid: true, errorMessage: nil)
        } else {
            updateCardNumberValidationState(isValid: false, errorMessage: "Invalid card number")
        }
    }

    private func validateCardNumberOnDefocus() {
        guard !cardNumberText.isEmpty else { return }

        let digitCount = cardNumberText.filter { $0.isNumber }.count

        let isInValidRange = digitCount >= Self.giftCardNumberMinDigits && digitCount <= Self.giftCardNumberMaxDigits

        if isInValidRange {
            updateCardNumberValidationState(isValid: true, errorMessage: nil)
        } else {
            updateCardNumberValidationState(isValid: false, errorMessage: "Invalid card number")
        }
    }

    private func updateCardNumberValidationState(isValid: Bool, errorMessage: String?) {
        cardNumberValid = isValid
        cardNumberError = errorMessage ?? ""
    }

    private func validatePin() {
        let digitCount = pinText.count

        if digitCount == Self.pinDigitCount {
            if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: pinText)) {
                pinValid = true
                pinError = ""
            } else {
                pinValid = false
                pinError = "Invalid PIN number"
            }
        } else if isPinBeingEdited && digitCount < Self.pinDigitCount {
            pinValid = nil
            pinError = ""
        } else {
            pinValid = false
            pinError = "Invalid PIN number"
        }
    }

    private func validatePinOnDefocus() {
        guard pinHadInput else { return }
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: pinText)) && pinText.count == Self.pinDigitCount {
            pinValid = true
            pinError = ""
        } else {
            pinValid = false
            pinError = "Invalid PIN number"
        }
    }

    func isFormValid() -> Bool {
        (pinValid ?? false) && (cardNumberValid ?? false)
    }

    /// Revalidates all fields and updates error messages. Call before tokenisation as a backup check.
    func revalidateAll() {
        validateCardNumberOnDefocus()
        validatePinOnDefocus()
    }

    /// Full-form validation for submit. Unlike the on-defocus validators, this flags empty fields too,
    /// records the first invalid field and the total error count, and returns whether the form is valid.
    /// Used when the primary button stays active (`activePrimaryButton`) so validation runs on tap.
    func validateForm() -> Bool {
        validateCardNumberForSubmit()
        validatePinForSubmit()

        if isFormValid() {
            firstFieldWithError = nil
            numberOfValidationFailures = 0
            return true
        }

        firstFieldWithError = nil
        var count = 0
        if cardNumberValid != true {
            firstFieldWithError = .cardNumber
            count += 1
        }
        if pinValid != true {
            if firstFieldWithError == nil { firstFieldWithError = .pin }
            count += 1
        }
        numberOfValidationFailures = count
        return false
    }

    private func validateCardNumberForSubmit() {
        let digitCount = cardNumberText.filter { $0.isNumber }.count
        let isInValidRange = digitCount >= Self.giftCardNumberMinDigits && digitCount <= Self.giftCardNumberMaxDigits
        updateCardNumberValidationState(isValid: isInValidRange, errorMessage: isInValidRange ? nil : "Invalid card number")
    }

    private func validatePinForSubmit() {
        let isValid = pinText.count == Self.pinDigitCount
            && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: pinText))
        pinValid = isValid
        pinError = isValid ? "" : "Invalid PIN number"
    }

    // MARK: - Formatting

    func formatCardNumber(updatedText: String, cursorPosition: Int) -> Int {
        let result = cardDetailsFormatter.formatGiftCardNumber(updatedText: updatedText, cursorPosition: cursorPosition)
        cardNumberText = result.formattedText
        return result.newCursorPosition
    }

    func formatPinNumber(updatedText: String, cursorPosition: Int) -> Int {
        let result = cardDetailsFormatter.formatGiftCardPin(updatedText: updatedText, cursorPosition: cursorPosition)
        pinText = result.formattedText
        return result.newCursorPosition
    }

    // MARK: - Editing

    func endEditing() {
        if editingCardNumber { validateCardNumberOnDefocus() }
        if editingPin { validatePinOnDefocus() }

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        editingCardNumber = false
        editingPin = false
        isCardNumberBeingEdited = false
        isPinBeingEdited = false
    }
}

// MARK: - GiftCardFocusable

extension GiftCardFormManager {

    enum GiftCardFocusable: Hashable {
        case cardNumber
        case pin
    }
}
