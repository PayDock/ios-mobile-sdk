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
    let config: CardDetailsWidgetConfig
    let appearance: CardDetailsWidgetAppearance

    // MARK: - Properties

    @Published var isLoading = false
    @Published var showLoaders = true
    @Published var policyAccepted = false {
        didSet {
            handleToggleFlipAnalytics()
        }
    }
    var viewState: ViewState
    var anyCancellable: AnyCancellable? // Required to allow updating the view from nested observable objects - SwiftUI quirk

    // MARK: - Handlers

    private weak var loadingDelegate: WidgetLoadingDelegate?
    private weak var eventDelegate: WidgetEventDelegate?
    private let completion: (Result<CardResult, CardDetailsError>) -> Void

    // MARK: - Initialisation

    init(cardService: CardService = CardServiceImpl(),
         viewState: ViewState,
         config: CardDetailsWidgetConfig,
         appearance: CardDetailsWidgetAppearance,
         loadingDelegate: WidgetLoadingDelegate?,
         eventDelegate: WidgetEventDelegate?,
         completion: @escaping (Result<CardResult, CardDetailsError>) -> Void) {
        self.cardService = cardService
        self.viewState = viewState
        self.config = config
        self.appearance = appearance
        self.loadingDelegate = loadingDelegate
        self.eventDelegate = eventDelegate
        self.completion = completion

        self.cardDetailsFormManager = CardDetailsFormManager(
            shouldValidateCardholderName: config.collectCardholderName,
            supportedSchemes: config.schemeSupport.supportedSchemes,
            enableCardValidation: config.schemeSupport.enableValidation
        )

        if loadingDelegate != nil {
            showLoaders = false
        }

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

            let trimmedCardName = cardDetailsFormManager.cardholderNameText.trimmingCharacters(in: .whitespacesAndNewlines)
            let cardName = trimmedCardName.isEmpty ? nil : trimmedCardName

            let tokeniseCardDetailsReq = TokeniseCardDetailsReq(
                gatewayId: config.gatewayId,
                cardName: cardName,
                cardNumber: cardDetailsFormManager.cardNumberText.replacingOccurrences(of: " ", with: ""),
                expireMonth: String(expireMonth),
                expireYear: String(expireYear),
                cardCcv: cardDetailsFormManager.securityCodeText)

            do {
                updateLoadingState(isLoading: true)
                let cardToken = try await cardService.createToken(
                    tokeniseCardDetailsReq: tokeniseCardDetailsReq,
                    accessToken: config.accessToken)

                updateLoadingState(isLoading: false)
                completion(.success(createResult(token: cardToken)))

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                updateLoadingState(isLoading: false)
                completion(.failure(.errorTokenisingCard(error: errorResponse)))

            } catch {
                updateLoadingState(isLoading: false)
                completion(.failure(.unknownError(error as? RequestError)))
            }
        }
    }

    // MARK: - Validation

    func isActionButtonDisabled() -> Bool {
        return viewState.isDisabled || !cardDetailsFormManager.isFormValid()
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

        self.isLoading = isLoading
        viewState.isDisabled = isLoading
    }

    private func createResult(token: String) -> CardResult {
        if config.allowSaveCard != nil {
            return CardResult(token: token, saveCard: policyAccepted)
        } else {
            return CardResult(token: token, saveCard: nil)
        }
    }

    // MARK: - Helpers

    func getSchemeIcon(for scheme: CardScheme) -> Image {
        switch scheme {
        case .amex: Image("american-express", bundle: Bundle.module)
        case .ausbc: Image("australian-commonwealth-bank", bundle: Bundle.module)
        case .diners: Image("diners", bundle: Bundle.module)
        case .discover: Image("discover", bundle: Bundle.module)
        case .japcb: Image("jcb", bundle: Bundle.module)
        case .mastercard: Image("mastercard", bundle: Bundle.module)
        case .solo: Image("solo", bundle: Bundle.module)
        case .visa: Image("visa", bundle: Bundle.module)
        case .unionpay: Image("unionpay", bundle: Bundle.module)
        }
    }

    // MARK: - Analytics Handling

    func handleTokenisationTapAnalytics() {
        let event = WidgetEvent(
            type: .button,
            properties: .button(
                WidgetEventButtonProperties(name: "TokenisationButton", action: .click, text: appearance.actionButton.text)))
        eventDelegate?.widgetEvent(event: event)
    }

    func handleToggleFlipAnalytics() {
        let event = WidgetEvent(
            type: .toggle,
            properties: .toggle(WidgetEventToggleProperties(name: "SaveCardToggle", action: .click, state: policyAccepted)))
        eventDelegate?.widgetEvent(event: event)
    }

    func handleLinkTapAnalytics(url: String) {
        let event = WidgetEvent(
            type: .linkText,
            properties: .linkText(WidgetEventLinkTextProperties(name: "PrivacyPolicyLink", action: .click, url: url))
        )
        eventDelegate?.widgetEvent(event: event)
    }
}
