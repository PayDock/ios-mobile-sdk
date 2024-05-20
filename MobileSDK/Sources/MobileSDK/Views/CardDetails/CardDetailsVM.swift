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

@MainActor
class CardDetailsVM: ObservableObject {

    // MARK: - Dependencies

    @Published var cardDetailsFormManager: CardDetailsFormManager
    @Published var isLoading = false
    private let cardService: CardService

    // MARK: - Properties

    private let gatewayId: String?
    private let completion: (Result<String, CardDetailsError>) -> Void

    var anyCancellable: AnyCancellable? = nil // Required to allow updating the view from nested observable objects - SwiftUI quirk

    // MARK: - Initialisation

    init(cardService: CardService = CardServiceImpl(),
         cardDetailsFormManager: CardDetailsFormManager = CardDetailsFormManager(),
         gatewayId: String?,
         completion: @escaping (Result<String, CardDetailsError>) -> Void) {
        self.cardService = cardService
        self.cardDetailsFormManager = cardDetailsFormManager
        self.gatewayId = gatewayId
        self.completion = completion

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

            let tokeniseCardDetailsReq = TokeniseCardDetailsReq(
                gatewayId: gatewayId,
                cardName: cardDetailsFormManager.cardholderNameText,
                cardNumber: cardDetailsFormManager.cardNumberText.replacingOccurrences(of: " ", with: ""),
                expireMonth: String(expireMonth),
                expireYear: String(expireYear),
                cardCcv: cardDetailsFormManager.securityCodeText)

            do {
                isLoading = true
                let cardToken = try await cardService.createToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq)
                isLoading = false
                completion(.success(cardToken))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                completion(.failure(.errorTokenisingCard(error: errorResponse)))
                isLoading = false
            } catch {
                completion(.failure(.unknownError))
                isLoading = false
            }
        }
    }
    
}
