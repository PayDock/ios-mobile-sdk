//
//  GiftCardVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 09.11.2023..
//

import Combine
import SwiftUI

class GiftCardVM: ObservableObject {

    // MARK: - Dependencies

    @Published var giftCardFormManager: GiftCardFormManager
    private let cardService: CardService
    
    // MARK: - Handlers

    private let completion: (Result<String, Error>) -> Void

    // MARK: - Properties

    private let storePin: Bool
    @Published var isLoading = false
    var anyCancellable: AnyCancellable? = nil // Required to allow updating the view from nested observable objects - SwiftUI quirk

    // MARK: - Initialisation

    init(giftCardFormManager: GiftCardFormManager = GiftCardFormManager(),
         cardService: CardService = CardServiceImpl(),
         storePin: Bool,
         completion: @escaping (Result<String, Error>) -> Void) {
        self.giftCardFormManager = giftCardFormManager
        self.cardService = cardService
        self.storePin = storePin
        self.completion = completion

        anyCancellable = giftCardFormManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    func tokeniseGiftCard() {
        Task {
            isLoading = true
            let tokeniseGiftCardReq = TokeniseGiftCardReq(
                cardNumber: giftCardFormManager.cardNumberText.replacingOccurrences(of: " ", with: ""),
                pin: giftCardFormManager.pinText,
                storePin: storePin)

            do {
                let cardToken = try await cardService.createGiftCardToken(tokeniseGiftCardReq: tokeniseGiftCardReq)
                isLoading = false
                completion(.success(cardToken))
            } catch {
                isLoading = false
                completion(.failure(error))
            }
        }
    }
}
