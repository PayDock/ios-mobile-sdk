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
    private let supportedSchemes: [CardScheme]?
    private let cardSchemeValidator: CardSchemeValidator
    private let cardExpiryDateValidator: CardExpiryDateValidatior
    private let cardSecurityCodeValidator: CardSecurityCodeValidator
    private let cardDetailsFormatter: CardDetailsFormatter
    
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
    @Published var securityCodeTitle = "CVC"

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
         supportedSchemes: [CardScheme]? = nil,
         cardIssuerValidator: CardSchemeValidator = CardSchemeValidator(),
         cardExpiryDateValidator: CardExpiryDateValidatior = CardExpiryDateValidatior(),
         cardSecurityCodeValidator: CardSecurityCodeValidator = CardSecurityCodeValidator(),
         cardExpiryDateFormatter: CardDetailsFormatter = CardDetailsFormatter()) {
        self.shouldValidateCardholderName = shouldValidateCardholderName
        self.supportedSchemes = supportedSchemes
        self.cardSchemeValidator = cardIssuerValidator
        self.cardExpiryDateValidator = cardExpiryDateValidator
        self.cardSecurityCodeValidator = cardSecurityCodeValidator
        self.cardDetailsFormatter = cardExpiryDateFormatter
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
        let cardScheme = cardSchemeValidator.detectCardScheme(number: cardNumberText)
        cardImage = getCardSchemeIcon(for: cardScheme)
    }

    func updateSecurityCodeTitleAndPlaceholder() {
        let cardScheme = cardSchemeValidator.detectCardScheme(number: cardNumberText)
        let cardSecurityCodeType = cardSecurityCodeValidator.detectSecurityCodeType(cardScheme: cardScheme)

        switch cardSecurityCodeType {
        case .cvv:
            securityCodeTitle = "CVV"
            securityCodePlaceholder = "XXX"

        case .csc:
            securityCodeTitle = "CSC"
            securityCodePlaceholder = "XXXX"

        case .cvc:
            securityCodeTitle = "CVC"
            securityCodePlaceholder = "XXX"
        }
    }

    private func getCardSchemeIcon(for cardScheme: CardScheme?) -> Image {
        switch cardScheme {
        case .amex: return Image("amex", bundle: Bundle.module)
        case .ausbc: return Image("ausbc", bundle: Bundle.module)
        case .diners: return Image("diners", bundle: Bundle.module)
        case .discover: return Image("discover", bundle: Bundle.module)
        case .japcb: return Image("jcb", bundle: Bundle.module)
        case .mastercard: return Image("mastercard", bundle: Bundle.module)
        case .visa: return Image("visa", bundle: Bundle.module)
        case .solo: return Image("solo", bundle: Bundle.module)
        default: return Image("credit-card", bundle: Bundle.module)
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
        if cardSchemeValidator.isValidCreditCardNumber(number: cardholderNameText) {
            cardHolderNameValid = false
            cardholderNameError = "Card number is in the wrong field!"

        } else if !cardholderNameText.isEmpty {
            cardHolderNameValid = true
            cardholderNameError = ""

        } else {
            cardHolderNameValid = false
            cardholderNameError = "Invalid name"
        }
    }

    private func validateCardNumber() {
        // Validate card number format
        guard cardSchemeValidator.isValidCreditCardNumber(number: cardNumberText) else {
            cardNumberValid = false
            cardNumberError = "Invalid card number"
            return
        }
        
        // Detect card issuer and map to scheme
        let cardScheme = cardSchemeValidator.detectCardScheme(number: cardNumberText)
        
        // Validate against supported schemes if provided
        if let supportedSchemes = supportedSchemes, !supportedSchemes.isEmpty {
            guard let scheme = cardScheme, supportedSchemes.contains(scheme) else {
                cardNumberValid = false
                cardNumberError = "Card type not accepted"
                return
            }
        }
        
        cardNumberValid = true
        cardNumberError = ""
    }

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

    private func validateSecurityCode() {
        let cardScheme = cardSchemeValidator.detectCardScheme(number: cardNumberText)
        let cardSecurityCodeType = cardSecurityCodeValidator.detectSecurityCodeType(cardScheme: cardScheme)

        if cardSecurityCodeValidator.isSecurityCodeValid(code: securityCodeText, securityCodeType: cardSecurityCodeType) {
            securityCodeValid = true
            securityCodeError = ""
        } else {
            securityCodeValid = false
            securityCodeError = "Invalid security code"
        }
    }

    func isFormValid() -> Bool {
        let cardHolderNameValid = shouldValidateCardholderName ? (!cardholderNameText.isEmpty && !cardSchemeValidator.isValidCreditCardNumber(number: cardholderNameText)) : true
        let creditCardValid = cardSchemeValidator.isValidCreditCardNumber(number: cardNumberText)
        let expiryValidation = cardExpiryDateValidator.validateCreditCardExpiry(stringDate: expiryDateText) == .valid
        
        let cardScheme = cardSchemeValidator.detectCardScheme(number: cardNumberText)
        let cardSecurityCodeType = cardSecurityCodeValidator.detectSecurityCodeType(cardScheme: cardScheme)
        let securityCodeValidation = cardSecurityCodeValidator.isSecurityCodeValid(code: securityCodeText, securityCodeType: cardSecurityCodeType)
        
        return cardHolderNameValid && creditCardValid && expiryValidation && securityCodeValidation
    }

    // MARK: - Formatting

    func formatCardNumber(updatedText: String) {
        cardNumberText = cardDetailsFormatter.formatCardNumber(updatedText: updatedText)
    }

    func formatExpiryDate(updatedText: String) {
        expiryDateText = cardDetailsFormatter.formatExpiryDate(updatedText: updatedText)
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
