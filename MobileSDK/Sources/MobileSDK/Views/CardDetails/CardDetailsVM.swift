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
    @Published var securityCodeError = ""

    @Published var editingCardholderName = false
    @Published var editingCardNumber = false
    @Published var editingExpiryDate = false
    @Published var editingSecurityCode = false

    @Published var cardHolderNameValid = true
    @Published var cardNumberValid = true
    @Published var expiryDateValid = true
    @Published var securityCodeValid = true

    @Published var cardImage: Image? = Image("credit-card", bundle: Bundle.module)

    let cardholderNameTitle = "Cardholder name"
    let cardNumberTitle = "Card number"
    let expiryDateTitle = "Expiry"
    @Published var securityCodeTitle = "CVC"

    var cardholderNamePlaceholder = ""
    var cardNumberPlaceholder = "XXXX XXXX XXXX XXXX"
    var expiryDatePlaceholder = "MM/YY"
    @Published var securityCodePlaceholder = "XXX"

    var cardholderNameText: String = ""
    private var cardNumberText: String = ""
    private var expiryDateText = ""
    var securityCodeText = ""

    private var currentTextField: CardDetailsFocusable?

    // MARK: - Custom bindings

    var cardNumberBinding: Binding<String> {
        Binding(
            get: {
                self.cardNumberText
            }, set: {
                self.cardNumberText = self.cardDetailsFormatter.formatCardNumber(updatedText: $0)
                self.updateCardIssuerIcon()
                self.updateSecurityCodeTitleAndPlaceholder()
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
            editingSecurityCode = false

        case .cardNumber:
            editingCardholderName = false
            editingCardNumber = true
            editingExpiryDate = false
            editingSecurityCode = false

        case .expiryDate:
            editingCardholderName = false
            editingCardNumber = false
            editingExpiryDate = true
            editingSecurityCode = false

        case .securityCode:
            editingCardholderName = false
            editingCardNumber = false
            editingExpiryDate = false
            editingSecurityCode = true
        }
    }

    private func updateCardIssuerIcon() {
        let cardIssuer = cardIssuerValidator.detectCardIssuer(number: cardNumberText)
        cardImage = getCardIssuerIcon(for: cardIssuer)
    }

    private func updateSecurityCodeTitleAndPlaceholder() {
        let cardIssuer = cardIssuerValidator.detectCardIssuer(number: cardNumberText)
        let cardSecurityCodeType = cardSecurityCodeValidator.detectSecurityCodeType(cardIssuer: cardIssuer)

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
        case .securityCode: validateSecurityCode()
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

    private func validateSecurityCode() {
        let cardIssuer = cardIssuerValidator.detectCardIssuer(number: cardNumberText)
        let cardSecurityCodeType = cardSecurityCodeValidator.detectSecurityCodeType(cardIssuer: cardIssuer)

        if cardSecurityCodeValidator.isSecurityCodeValid(code: securityCodeText, securityCodeType: cardSecurityCodeType) {
            securityCodeValid = true
            securityCodeError = ""
        } else {
            securityCodeValid = false
            securityCodeError = "Invalid security code"
        }
    }

    // MARK: - Api Calls

    func tokeniseCardDetails() {
        Task {
            guard let expireMonth = expiryDateText.split(separator: "/").first,
                  let expireYear = expiryDateText.split(separator: "/").last else {
                return
            }

            let tokeniseCardDetailsReq = TokeniseCardDetailsReq(
                gatewayId: gatewayId,
                cardName: cardholderNameText,
                cardNumber: cardNumberText,
                expireMonth: String(expireMonth),
                expireYear: String(expireYear),
                cardCcv: securityCodeText)

            do {
                let cardToken = try await cardService.createToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq)
                onCompletion?.wrappedValue = cardToken

            } catch {
                // TODO: - Error popups and handling once designs are finalised.
                print("Error tokenising card")
            }
        }
    }
    
}

extension CardDetailsVM {

    enum CardDetailsFocusable: Hashable {
        case cardholderName
        case cardNumber
        case expiryDate
        case securityCode
    }

}
