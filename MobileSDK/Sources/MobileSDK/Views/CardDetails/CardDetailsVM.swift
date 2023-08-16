//
//  CardDetailsVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 02.08.2023..
//

import Foundation
import SwiftUI

class CardDetailsVM: ObservableObject {

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
    var cardNumberText: String = ""
    var expiryDateText = ""
    var cvcText = ""

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

    // MARK: - Methods

    func validateCardholderName() {
        cardHolderNameValid = !cardholderNameText.isEmpty
    }

    func validateCardNumber() {
        print(cardNumberText)
      cardNumberValid.toggle() // Test validation.
    }

    func validateExpiryDate() {
        expiryDateValid.toggle()
    }

    func validateCVC() {
        cvcValid.toggle()
    }

    enum CardDetailsFocusable: Hashable {
        case cardholderName
        case cardNumber
        case expiryDate
        case cvc
    }
    
}
