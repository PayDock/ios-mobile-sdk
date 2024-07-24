//
//  GiftCardVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 09.11.2023..
//

import Combine
import SwiftUI
import NetworkingLib

class GiftCardVM: ObservableObject {

    // MARK: - Dependencies

    @Published var giftCardFormManager: GiftCardFormManager
    private let cardService: CardService
    private let accessToken: String
    private let storePin: Bool

    // MARK: - Handlers

    private let completion: (Result<String, GiftCardError>) -> Void

    // MARK: - Properties

    @Published var isLoading = false
    var anyCancellable: AnyCancellable? = nil // Required to allow updating the view from nested observable objects - SwiftUI quirk

    // MARK: - Initialisation

    init(giftCardFormManager: GiftCardFormManager = GiftCardFormManager(),
         cardService: CardService = CardServiceImpl(),
         accessToken: String,
         storePin: Bool,
         completion: @escaping (Result<String, GiftCardError>) -> Void) {
        self.giftCardFormManager = giftCardFormManager
        self.cardService = cardService
        self.accessToken = accessToken
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
                let cardToken = try await cardService.createGiftCardToken(tokeniseGiftCardReq: tokeniseGiftCardReq, accessToken: accessToken)
                isLoading = false
                completion(.success(cardToken))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                isLoading = false
                completion(.failure(.errorTokenisingCard(error: errorResponse)))
            } catch {
                completion(.failure(.unknownError))
            }
        }
    }
}
