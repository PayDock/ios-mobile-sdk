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

    @Published var cardNumberValid = true
    @Published var pinValid = true

    let cardNumberTitle = "Card number"
    let pinTitle = "PIN"

    var cardNumberPlaceholder = "XXXX XXXX XXXX XXXX"
    @Published var pinPlaceholder = "XXXX"

    private(set) var cardNumberText: String = ""
    private(set) var pinText = ""

    private var currentTextField: GiftCardFocusable?

    var cardNumberBinding: Binding<String> {
        Binding(
            get: {
                self.cardNumberText
            }, set: {
                self.cardNumberText = self.formatCardNumber(updatedText: $0)
                if !self.cardNumberValid {
                    self.validateTextField(.cardNumber)
                }
            }
        )
    }

    var pinBinding: Binding<String> {
        Binding(
            get: {
                self.pinText
            }, set: {
                self.pinText = $0
                if !self.pinValid {
                    self.validateTextField(.pin)
                }
            }
        )
    }

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
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: pinText)) {
            pinValid = true
            pinError = ""
        } else {
            pinValid = false
            pinError = "Invalid PIN number"
        }
    }

    // MARK: - Formatting

    func formatCardNumber(updatedText: String) -> String {
        cardDetailsFormatter.formatCardNumber(updatedText: updatedText)
    }

}

// MARK: - GiftCardFocusable

extension GiftCardFormManager {

    enum GiftCardFocusable: Hashable {
        case cardNumber
        case pin
    }

}

