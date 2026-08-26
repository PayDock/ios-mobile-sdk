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
import DataPaymentSources

@MainActor
class GiftCardVM: ObservableObject {

    // MARK: - Dependencies

    let appearance: GiftCardWidgetAppearance
    @Published var giftCardFormManager: GiftCardFormManager
    private let paymentSourcesService: DataPaymentSources.PaymentSourcesService
    let config: GiftCardWidgetConfig
    var viewState: ViewState

    // MARK: - Handlers

    private let completion: (Result<GiftCardResult, GiftCardError>) -> Void

    // MARK: - Properties

    @Published var isLoading = false
    // Set false when a loadingDelegate is supplied, so the internal button doesn't show its own
    // spinner on top of whatever loading UI the host's delegate is driving. `isLoading` itself is
    // still always kept accurate (see updateLoadingState) so it remains usable as a reentrancy guard
    // regardless of delegate presence — only its effect on the button's spinner is gated separately.
    @Published var showLoaders = true
    private weak var loadingDelegate: WidgetLoadingDelegate?
    private weak var eventDelegate: WidgetEventDelegate?

    var anyCancellable: AnyCancellable? // Required to allow updating the view from nested observable objects - SwiftUI quirk

    var numberOfValidationErrors: Int {
        giftCardFormManager.numberOfValidationFailures
    }
    var firstTextFieldWithError: GiftCardFormManager.GiftCardFocusable? {
        giftCardFormManager.firstFieldWithError
    }

    // MARK: - Initialisation

    init(appearance: GiftCardWidgetAppearance,
         viewState: ViewState,
         giftCardFormManager: GiftCardFormManager = GiftCardFormManager(),
         paymentSourcesService: DataPaymentSources.PaymentSourcesService = DataPaymentSources.PaymentSourcesServiceImpl(),
         config: GiftCardWidgetConfig,
         loadingDelegate: WidgetLoadingDelegate?,
         eventDelegate: WidgetEventDelegate?,
         completion: @escaping (Result<GiftCardResult, GiftCardError>) -> Void) {
        self.appearance = appearance
        self.viewState = viewState
        self.giftCardFormManager = giftCardFormManager
        self.paymentSourcesService = paymentSourcesService
        self.config = config
        self.loadingDelegate = loadingDelegate
        self.eventDelegate = eventDelegate
        self.completion = completion

        if loadingDelegate != nil {
            showLoaders = false
        }

        anyCancellable = giftCardFormManager.objectWillChange.sink { [weak self] _ in
            // Defer to avoid publishing during view updates
            Task {
                self?.objectWillChange.send()
            }
        }
    }

    // MARK: - Requests

    func tokeniseGiftCard() {
        giftCardFormManager.revalidateAll()
        guard giftCardFormManager.isFormValid() else { return }
        // Transition to loading synchronously (before dispatching the Task), so a second call
        // arriving before the Task body has actually started still sees isLoading == true rather
        // than racing it — this is what makes callers' own re-entrancy guards durable.
        guard !isLoading else { return }
        updateLoadingState(isLoading: true)

        Task {
            let tokeniseGiftCardReq = CreateGiftCardTokenReq(
                cardNumber: giftCardFormManager.cardNumberText.replacingOccurrences(of: " ", with: ""),
                cardPin: giftCardFormManager.pinText,
                storePin: config.storePin)

            do {
                let cardToken = try await paymentSourcesService.createGiftCardToken(
                    tokeniseGiftCardReq: tokeniseGiftCardReq,
                    widgetAccessToken: config.accessToken)
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
        }
        // Always kept accurate regardless of delegate presence — showLoaders (not this) is what
        // gates whether the internal button's own spinner renders when a delegate is supplied.
        self.isLoading = isLoading
        viewState.isDisabled = isLoading
    }

    func isActionButtonDisabled() -> Bool {
        if config.activePrimaryButton {
            // Keep the button tappable so validation runs on tap; still block re-taps while loading.
            return viewState.isDisabled
        }
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
