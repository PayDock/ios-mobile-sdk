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

    private let cardService: CardService

    // MARK: - Properties

    var gatewayId: String = ""
    var onCompletion: Binding<String>?

    @Published var cardholderNameError = ""
    @Published var cardNumberError = ""
    @Published var expiryDateError = ""
    @Published var cvcError = ""

    @Published var editingCardholderName = false
    @Published var editingCardNumber = false
    @Published var editingExpiryDate = false
    @Published var editingCVC = false

    @Published var cardHolderNameValid = true
    @Published var cardNumberValid = true
    @Published var expiryDateValid = true
    @Published var cvcValid = true

    @Published var cardImage: Image? = Image("credit-card", bundle: Bundle.module)

    let cardholderNamePlaceholder = "Cardholder name"
    let cardNumberPlaceholder = "Card number"
    let expiryDatePlaceholder = "Expiry"
    @Published var cvcPlaceholder = "CVC"

    var cardholderNameText: String = ""
    private var cardNumberText: String = ""
    private var expiryDateText = ""
    var cvcText = ""

    private var currentTextField: CardDetailsFocusable?

    // MARK: - Custom bindings

    var cardNumberBinding: Binding<String> {
        Binding(
            get: {
                self.cardNumberText
            }, set: {
                self.cardNumberText = self.cardDetailsFormatter.formatCardNumber(updatedText: $0)
                self.updateCardIssuerIcon()
                self.updateSecurityCodePlaceholder()
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
         cardExpiryDateFormatter: CardDetailsFormatter = CardDetailsFormatter(),
         cardService: CardService = CardServiceImpl()) {
        self.cardIssuerValidator = cardIssuerValidator
        self.cardExpiryDateValidator = cardExpiryDateValidator
        self.cardSecurityCodeValidator = cardSecurityCodeValidator
        self.cardDetailsFormatter = cardExpiryDateFormatter
        self.cardService = cardService
    }

    // MARK: - Methods

    func setEditingTextField(focusedField: CardDetailsFocusable?) {
        validateOldTextField(currentTextField)
        currentTextField = focusedField

        guard let focusedField = focusedField else { return }
        switch focusedField {
        case .cardholderName:
            editingCardholderName = true
            editingCardNumber = false
            editingExpiryDate = false
            editingCVC = false

        case .cardNumber:
            editingCardholderName = false
            editingCardNumber = true
            editingExpiryDate = false
            editingCVC = false

        case .expiryDate:
            editingCardholderName = false
            editingCardNumber = false
            editingExpiryDate = true
            editingCVC = false

        case .cvc:
            editingCardholderName = false
            editingCardNumber = false
            editingExpiryDate = false
            editingCVC = true
        }
    }

    private func updateCardIssuerIcon() {
        let cardIssuer = cardIssuerValidator.detectCardIssuer(number: cardNumberText)
        cardImage = getCardIssuerIcon(for: cardIssuer)
    }

    private func updateSecurityCodePlaceholder() {
        let cardIssuer = cardIssuerValidator.detectCardIssuer(number: cardNumberText)
        let cardSecurityCodeType = cardSecurityCodeValidator.detectSecurityCodeType(cardIssuer: cardIssuer)

        switch cardSecurityCodeType {
        case .cvv: cvcPlaceholder = "CVV"
        case .csc: cvcPlaceholder = "CSC"
        case .cvc: cvcPlaceholder = "CVC"
        }
    }

    private func getCardIssuerIcon(for cardIssuerType: CardIssuerType) -> Image {
        switch cardIssuerType {
        case .amex: return Image("amex", bundle: Bundle.module)
        case .diners: return Image("diners", bundle: Bundle.module)
        case .discover: return Image("discover", bundle: Bundle.module)
        case .instaPayment: return Image("insta-payment", bundle: Bundle.module)
        case .interPay: return Image("inter-payment", bundle: Bundle.module)
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

    private func validateOldTextField(_ textField: CardDetailsFocusable?) {
        guard let textField = textField else { return }

        switch textField {
        case .cardholderName: validateCardholderName()
        case .cardNumber: validateCardNumber()
        case .expiryDate: validateExpiryDate()
        case .cvc: validateCVC()
        }
    }

    private func validateCardholderName() {
        if !cardholderNameText.isEmpty {
            cardHolderNameValid = true
            cardholderNameError = ""

        } else {
            cardHolderNameValid = false
            cardholderNameError = "Invalid name"
        }
    }

    private func validateCardNumber() {
        if case .other = cardIssuerValidator.detectCardIssuer(number: cardNumberText) {
            cardNumberValid = false
            cardNumberError = "Invalid card number"
        } else {
            cardNumberValid = true
            cardNumberError = ""
        }
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

    private func validateCVC() {
        let cardIssuer = cardIssuerValidator.detectCardIssuer(number: cardNumberText)
        let cardSecurityCodeType = cardSecurityCodeValidator.detectSecurityCodeType(cardIssuer: cardIssuer)

        if cardSecurityCodeValidator.isSecurityCodeValid(code: cvcText, securityCodeType: cardSecurityCodeType) {
            cvcValid = true
            cvcError = ""
        } else {
            cvcValid = false
            cvcError = "Invalid security code"
        }
    }

    // MARK: - Api Calls

    func tokeniseCardDetails() {
        Task {
            do {
                let tokeniseCardDetailsReq = TokeniseCardDetailsReq(
                    gatewayId: gatewayId,
                    cardName: cardholderNameText,
                    cardNumber: cardNumberText,
                    expireMonth: "09",
                    expireYear: "24",
                    cardCcv: cvcText)
                let cardToken = try await cardService.createToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq)
                onCompletion?.wrappedValue = cardToken
            } catch {
                onCompletion?.wrappedValue = "Pimpek"
                print("KAOS")
            }
        }
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
