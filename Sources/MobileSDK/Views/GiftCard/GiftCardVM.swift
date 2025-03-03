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
    @Published var isDisabled = false
    private weak var loadingDelegate: WidgetLoadingDelegate?
    
    var anyCancellable: AnyCancellable? = nil // Required to allow updating the view from nested observable objects - SwiftUI quirk

    // MARK: - Initialisation

    init(giftCardFormManager: GiftCardFormManager = GiftCardFormManager(),
         cardService: CardService = CardServiceImpl(),
         accessToken: String,
         storePin: Bool,
         loadingDelegate: WidgetLoadingDelegate?,
         completion: @escaping (Result<String, GiftCardError>) -> Void) {
        self.giftCardFormManager = giftCardFormManager
        self.cardService = cardService
        self.accessToken = accessToken
        self.storePin = storePin
        self.loadingDelegate = loadingDelegate
        self.completion = completion

        anyCancellable = giftCardFormManager.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    // MARK: - Requests

    func tokeniseGiftCard() {
        Task {
            updateLoadingState(isLoading: true)
            let tokeniseGiftCardReq = TokeniseGiftCardReq(
                cardNumber: giftCardFormManager.cardNumberText.replacingOccurrences(of: " ", with: ""),
                pin: giftCardFormManager.pinText,
                storePin: storePin)

            do {
                let cardToken = try await cardService.createGiftCardToken(tokeniseGiftCardReq: tokeniseGiftCardReq, accessToken: accessToken)
                updateLoadingState(isLoading: false)
                completion(.success(cardToken))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                updateLoadingState(isLoading: false)
                completion(.failure(.errorTokenisingCard(error: errorResponse)))
            } catch {
                updateLoadingState(isLoading: false)
                completion(.failure(.unknownError))
            }
        }
    }
    
    // MARK: - State Management
    
    func updateLoadingState(isLoading: Bool) {
        if (loadingDelegate != nil) {
            if (isLoading) {
                loadingDelegate?.loadingDidStart()
            } else {
                loadingDelegate?.loadingDidFinish()
            }
        } else {
            self.isLoading = isLoading
        }
        self.isDisabled = isLoading
    }
}
