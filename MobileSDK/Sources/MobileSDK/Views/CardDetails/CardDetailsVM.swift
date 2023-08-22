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

    var cardDetailsFormManager: CardDetailsFormManager
    private let cardService: CardService

    // MARK: - Properties

    var gatewayId: String = ""
    var onCompletion: Binding<String>?

    // MARK: - Initialisation

    init(cardService: CardService = CardServiceImpl(),
         cardDetailsFormManager: CardDetailsFormManager = CardDetailsFormManager()) {
        self.cardService = cardService
        self.cardDetailsFormManager = cardDetailsFormManager
    }

    // MARK: - Api Calls

    func tokeniseCardDetails() {
        Task {
            guard let expireMonth = self.cardDetailsFormManager.expiryDateText.split(separator: "/").first,
                  let expireYear = self.cardDetailsFormManager.expiryDateText.split(separator: "/").last else {
                return
            }

            let tokeniseCardDetailsReq = TokeniseCardDetailsReq(
                gatewayId: gatewayId,
                cardName: cardDetailsFormManager.cardholderNameText,
                cardNumber: cardDetailsFormManager.cardNumberText,
                expireMonth: String(expireMonth),
                expireYear: String(expireYear),
                cardCcv: cardDetailsFormManager.securityCodeText)

            do {
                let cardToken = try await cardService.createToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq)
                onCompletion?.wrappedValue = cardToken

            } catch {
                // TODO: - Error popups and handling once designs are finalised.
                onCompletion?.wrappedValue = "Error tokenising card!"
            }
        }
    }
    
}
