//
//  CardDetailsVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 02.08.2023..
//

import Foundation
import SwiftUI
import Combine
import NetworkingLib

@MainActor
class CardDetailsVM: ObservableObject {

    // MARK: - Dependencies

    @Published var cardDetailsFormManager: CardDetailsFormManager
    private let cardService: CardService
    private let accessToken: String

    // MARK: - Properties

    private let gatewayId: String?
    let actionText: String
    let showCardTitle: Bool
    let collectCardholderName: Bool
    let allowSaveCard: SaveCardConfig?
    private let completion: (Result<CardResult, CardDetailsError>) -> Void

    @Published var isLoading = false
    @Published var policyAccepted = false

    var anyCancellable: AnyCancellable? = nil // Required to allow updating the view from nested observable objects - SwiftUI quirk

    // MARK: - Initialisation

    init(cardService: CardService = CardServiceImpl(),
         gatewayId: String?,
         accessToken: String,
         actionText: String,
         showCardTitle: Bool,
         collectCardholderName: Bool,
         allowSaveCard: SaveCardConfig?,
         completion: @escaping (Result<CardResult, CardDetailsError>) -> Void) {
        self.cardService = cardService
        self.gatewayId = gatewayId
        self.accessToken = accessToken
        self.actionText = actionText
        self.showCardTitle = showCardTitle
        self.collectCardholderName = collectCardholderName
        self.allowSaveCard = allowSaveCard
        self.completion = completion
        
        self.cardDetailsFormManager = CardDetailsFormManager(shouldValidateCardholderName: collectCardholderName)

        anyCancellable = cardDetailsFormManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    // MARK: - Api Calls

    func tokeniseCardDetails() {
        Task {
            guard let expireMonth = self.cardDetailsFormManager.expiryDateText.split(separator: "/").first,
                  let expireYear = self.cardDetailsFormManager.expiryDateText.split(separator: "/").last else {
                return
            }
            
            let cardName = cardDetailsFormManager.cardholderNameText.isEmpty ? nil : cardDetailsFormManager.cardholderNameText

            let tokeniseCardDetailsReq = TokeniseCardDetailsReq(
                gatewayId: gatewayId,
                cardName: cardName,
                cardNumber: cardDetailsFormManager.cardNumberText.replacingOccurrences(of: " ", with: ""),
                expireMonth: String(expireMonth),
                expireYear: String(expireYear),
                cardCcv: cardDetailsFormManager.securityCodeText)

            do {
                isLoading = true
                let cardToken = try await cardService.createToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq, accessToken: accessToken)
                isLoading = false
                completion(.success(createResult(token: cardToken)))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                completion(.failure(.errorTokenisingCard(error: errorResponse)))
                isLoading = false
            } catch {
                completion(.failure(.unknownError))
                isLoading = false
            }
        }
    }

    private func createResult(token: String) -> CardResult {
        if let allowSaveCard = allowSaveCard {
            return CardResult(token: token, saveCard: policyAccepted)
        } else {
            return CardResult(token: token, saveCard: nil)
        }
    }

}
