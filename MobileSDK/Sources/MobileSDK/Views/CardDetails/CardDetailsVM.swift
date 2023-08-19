//
//  CardDetailsVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 02.08.2023..
//

import Foundation
import SwiftUI

class CardDetailsVM: ObservableObject {

    // MARK: - Dependencies

    private let cardIssuerValidator: CardIssuerValidator
    private let cardExpiryDateValidator: CardExpiryDateValidatior
    private let cardSecurityCodeValidator: CardSecurityCodeValidator
    private let cardDetailsFormatter: CardDetailsFormatter

    // MARK: - Properties

    @Published var cardholderNameError = ""
    @Published var cardNumberError = ""
    @Published var expiryDateError = ""
    @Published var cvcError = ""

    @Published var editingCardholderName = false
    @Published var editingCardNumber = false
    @Published var editingExpiryDate = false
    @Published var editingCVC = false

    @Published var cardHolderNameValid = true {
      didSet {
        cardholderNameError = cardHolderNameValid ? "" : "Error 1"
      }
    }

    @Published var cardNumberValid = true {
      didSet {
        cardNumberError = cardNumberValid ? "" : "Error 2"
      }
    }

    @Published var expiryDateValid = true {
      didSet {
        expiryDateError = expiryDateValid ? "" : "Error 2"
      }
    }

    @Published var cvcValid = true {
      didSet {
        cvcError = cvcValid ? "" : "Error 2"
      }
    }

    @Published var cardImage: Image? = Image("credit-card", bundle: Bundle.module)

    let cardholderNamePlaceholder = "Cardholder name"
    let cardNumberPlaceholder = "Card number"
    let expiryDatePlaceholder = "Expiry"
    let cvcPlaceholder = "CVC"

    var cardholderNameText: String = ""
    private var cardNumberText: String = ""
    private var expiryDateText = ""
    var cvcText = ""

    // MARK: - Custom bindings

    var cardNumberBinding: Binding<String> {
        Binding(
            get: {
                self.cardNumberText
            }, set: {
                self.cardNumberText = self.cardDetailsFormatter.formatCardNumber(updatedText: $0)
                self.updateCardIssuerIcon()
            }
        )
    }

    var expiryDateBinding: Binding<String> {
        Binding(
            get: {
                self.expiryDateText
            }, set: {
                let newText = self.cardDetailsFormatter.formatExpiryDate(updatedText: $0)
                self.expiryDateText = newText
            }
        )
    }

    // MARK: - Initialisation

    init(cardIssuerValidator: CardIssuerValidator = CardIssuerValidator(),
         cardExpiryDateValidator: CardExpiryDateValidatior = CardExpiryDateValidatior(),
         cardSecurityCodeValidator: CardSecurityCodeValidator = CardSecurityCodeValidator(),
         cardExpiryDateFormatter: CardDetailsFormatter = CardDetailsFormatter()) {
        self.cardIssuerValidator = cardIssuerValidator
        self.cardExpiryDateValidator = cardExpiryDateValidator
        self.cardSecurityCodeValidator = cardSecurityCodeValidator
        self.cardDetailsFormatter = cardExpiryDateFormatter
    }

    // MARK: - Methods

    func setEditingTextField(focusedField: CardDetailsFocusable?) {
        guard let focusedField = focusedField else { return }
        switch focusedField {
        case .cardholderName:
            editingCardholderName = true
            editingCardNumber = false
            editingExpiryDate = false
            editingCVC = false

            validateCardNumber()
            validateExpiryDate()
            validateCVC()

        case .cardNumber:
            editingCardholderName = false
            editingCardNumber = true
            editingExpiryDate = false
            editingCVC = false

            validateCardholderName()
            validateExpiryDate()
            validateCVC()

        case .expiryDate:
            editingCardholderName = false
            editingCardNumber = false
            editingExpiryDate = true
            editingCVC = false

            validateCardholderName()
            validateCardholderName()
            validateCVC()

        case .cvc:
            editingCardholderName = false
            editingCardNumber = false
            editingExpiryDate = false
            editingCVC = true

            validateCardholderName()
            validateCardholderName()
            validateExpiryDate()
        }
    }

    private func updateCardIssuerIcon() {
        let cardIssuer = cardIssuerValidator.detectCardIssuer(number: cardNumberText)
        cardImage = getCardIssuerIcon(for: cardIssuer)
    }

    private func getCardIssuerIcon(for cardIssuerType: CardIssuerType) -> Image {
        switch cardIssuerType {
        case .amex: return Image("amex", bundle: Bundle.module)
        case .diners: return Image("diners", bundle: Bundle.module)
        case .discover: return Image("discover", bundle: Bundle.module)
        case .instaPayment: return Image("insta-payment", bundle: Bundle.module)
        case .interPay: return Image("inter-pay", bundle: Bundle.module)
        case .jcb: return Image("jcb", bundle: Bundle.module)
        case .maestro: return Image("maestro", bundle: Bundle.module)
        case .mastercard: return Image("mastercard", bundle: Bundle.module)
        case .uatp: return Image("uatp", bundle: Bundle.module)
        case .unionPay: return Image("union-pay", bundle: Bundle.module)
        case .visa: return Image("visa", bundle: Bundle.module)
        case .other: return Image("credit-card", bundle: Bundle.module)
        }
    }

    // MARK: - Validations

    func validateCardholderName() {
        cardHolderNameValid = !cardholderNameText.isEmpty
    }

    func validateCardNumber() {
        if case .other = cardIssuerValidator.detectCardIssuer(number: cardNumberText) {
            cardNumberValid = false
        } else {
            cardNumberValid = true
        }
    }

    func validateExpiryDate() {
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

    func validateCVC() {
        let cardIssuer = cardIssuerValidator.detectCardIssuer(number: cardNumberText)
        let cardSecurityCodeType = cardSecurityCodeValidator.detectSecurityCodeType(cardIssuer: cardIssuer)
        cvcValid = cardSecurityCodeValidator.isSecurityCodeValid(code: cvcText, securityCodeType: cardSecurityCodeType)
    }
    
}

extension CardDetailsVM {

    enum CardDetailsFocusable: Hashable {
        case cardholderName
        case cardNumber
        case expiryDate
        case cvc
    }

}
