//
//  GiftCardFormManager.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 13.11.2023..
//

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

    var cardNumberPlaceholder = "XXXX XXXX XXXX XXXX"
    @Published var pinPlaceholder = "XXXX"

    var cardNumberText: String = "" {
        didSet {
            if !cardNumberText.isEmpty {
                self.validateTextField(.cardNumber)
            }
        }
    }
    var pinText = "" {
        didSet {
            if !pinText.isEmpty {
                self.validateTextField(.pin)
            }
        }
    }

    private var currentTextField: GiftCardFocusable?

    // MARK: - Initialisation

    init(cardDetailsFormatter: CardDetailsFormatter = CardDetailsFormatter()) {
        self.cardDetailsFormatter = cardDetailsFormatter
    }

    // MARK: - Methods

    func setEditingTextField(focusedField: GiftCardFocusable?) {
        validateTextField(currentTextField)
        currentTextField = focusedField

        guard let focusedField = focusedField else { return }

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
        let cardNumberProper = cardNumberText.replacingOccurrences(of: " ", with: "")

        if cardNumberProper.count >= 14 && cardNumberProper.count <= 25 {
            cardNumberValid = true
            cardNumberError = ""
        } else {
            cardNumberValid = false
            cardNumberError = "Invalid card number"
        }
    }

    private func validatePin() {
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: pinText)) && pinText.count >= 4 {
            pinValid = true
            pinError = ""
        } else {
            pinValid = false
            pinError = "Invalid PIN number"
        }
    }
    
    func isFormValid() -> Bool {
        return pinValid ?? false && cardNumberValid ?? false
    }

    // MARK: - Formatting

    func formatCardNumber(updatedText: String) -> String {
        cardDetailsFormatter.formatCardNumber(updatedText: updatedText)
    }
    
    // MARK: - Editing
    
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        editingCardNumber = false
        editingPin = false
    }
}

// MARK: - GiftCardFocusable

extension GiftCardFormManager {

    enum GiftCardFocusable: Hashable {
        case cardNumber
        case pin
    }
}

