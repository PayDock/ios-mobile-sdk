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

@MainActor
class GiftCardVM: ObservableObject {

    // MARK: - Dependencies

    let appearance: GiftCardWidgetAppearance
    @Published var giftCardFormManager: GiftCardFormManager
    private let cardService: CardService
    private let config: GiftCardWidgetConfig
    var viewState: ViewState

    // MARK: - Handlers

    private let completion: (Result<GiftCardResult, GiftCardError>) -> Void

    // MARK: - Properties

    @Published var isLoading = false
    private weak var loadingDelegate: WidgetLoadingDelegate?
    private weak var eventDelegate: WidgetEventDelegate?

    var anyCancellable: AnyCancellable? // Required to allow updating the view from nested observable objects - SwiftUI quirk

    // MARK: - Initialisation

    init(appearance: GiftCardWidgetAppearance,
         viewState: ViewState,
         giftCardFormManager: GiftCardFormManager = GiftCardFormManager(),
         cardService: CardService = CardServiceImpl(),
         config: GiftCardWidgetConfig,
         loadingDelegate: WidgetLoadingDelegate?,
         eventDelegate: WidgetEventDelegate?,
         completion: @escaping (Result<GiftCardResult, GiftCardError>) -> Void) {
        self.appearance = appearance
        self.viewState = viewState
        self.giftCardFormManager = giftCardFormManager
        self.cardService = cardService
        self.config = config
        self.loadingDelegate = loadingDelegate
        self.eventDelegate = eventDelegate
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
                storePin: config.storePin)

            do {
                let cardToken = try await cardService.createGiftCardToken(
                    tokeniseGiftCardReq: tokeniseGiftCardReq,
                    accessToken: config.accessToken)
                updateLoadingState(isLoading: false)
                completion(.success(GiftCardResult(token: cardToken)))

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                updateLoadingState(isLoading: false)
                completion(.failure(.errorTokenisingCard(error: errorResponse)))

            } catch {
                updateLoadingState(isLoading: false)
                completion(.failure(.unknownError(error as? RequestError)))
            }
        }
    }

    // MARK: - State Management

    func updateLoadingState(isLoading: Bool) {
        if loadingDelegate != nil {
            if isLoading {
                loadingDelegate?.loadingDidStart()
            } else {
                loadingDelegate?.loadingDidFinish()
            }
        } else {
            self.isLoading = isLoading
        }
        viewState.isDisabled = isLoading
    }

    func isActionButtonDisabled() -> Bool {
        return !giftCardFormManager.isFormValid() || viewState.isDisabled
    }

    // MARK: - Analytics Handling

    func handleButtonTapAnalytics() {
        let event = WidgetEvent(
            type: .button,
            properties: .button(
                WidgetEventButtonProperties(name: "TokenisationButton", action: .click, text: appearance.actionButton.text)))
        eventDelegate?.widgetEvent(event: event)
    }
}
