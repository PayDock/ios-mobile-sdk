//
//  GiftCardVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 09.11.2023..
//

import Combine
import SwiftUI

class GiftCardVM: ObservableObject {

    // MARK: - Dependencies

    @Published var giftCardFormManager: GiftCardFormManager
    private let cardService: CardService
    
    // MARK: - Handlers

    private var onCompletion: Binding<String?>
    private var onFailure: Binding<Error?>

    // MARK: - Properties

    private let storePin: Bool

    var anyCancellable: AnyCancellable? = nil // Required to allow updating the view from nested observable objects - SwiftUI quirk

    // MARK: - Initialisation

    init(giftCardFormManager: GiftCardFormManager = GiftCardFormManager(),
         cardService: CardService = CardServiceImpl(),
         storePin: Bool,
         onCompletion: Binding<String?>,
         onFailure: Binding<Error?>) {
        self.giftCardFormManager = giftCardFormManager
        self.cardService = cardService
        self.storePin = storePin
        self.onCompletion = onCompletion
        self.onFailure = onFailure

        anyCancellable = giftCardFormManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    func tokeniseGiftCard() {
        Task {
            let tokeniseGiftCardReq = TokeniseGiftCardReq(
                cardNumber: giftCardFormManager.cardNumberText.replacingOccurrences(of: " ", with: ""),
                pin: giftCardFormManager.pinText,
                storePin: storePin)

            do {
                let cardToken = try await cardService.createGiftCardToken(tokeniseGiftCardReq: tokeniseGiftCardReq)
                onCompletion.wrappedValue = cardToken

            } catch {
                onFailure.wrappedValue = error
            }
        }
    }
}
