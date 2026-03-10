//
//  CardDetailsVM.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI
import Combine
import NetworkingLib
import DataPaymentSources

@MainActor
class CardDetailsVM: ObservableObject {

    // MARK: - Dependencies

    @Published var cardDetailsFormManager: CardDetailsFormManager
    private let paymentSourcesService: DataPaymentSources.PaymentSourcesService
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

    init(paymentSourcesService: DataPaymentSources.PaymentSourcesService = DataPaymentSources.PaymentSourcesServiceImpl(),
         viewState: ViewState,
         config: CardDetailsWidgetConfig,
         appearance: CardDetailsWidgetAppearance,
         loadingDelegate: WidgetLoadingDelegate?,
         eventDelegate: WidgetEventDelegate?,
         completion: @escaping (Result<CardResult, CardDetailsError>) -> Void) {
        self.paymentSourcesService = paymentSourcesService
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
            // Defer to avoid publishing during view updates
            Task {
                self?.objectWillChange.send()
            }
        }
    }

    // MARK: - Api Calls

    func tokeniseCardDetails() {
        guard cardDetailsFormManager.isFormValid() else {
            return
        }

        Task {
            guard let expireMonth = self.cardDetailsFormManager.expiryDateText.split(separator: "/").first,
                  let expireYear = self.cardDetailsFormManager.expiryDateText.split(separator: "/").last else {
                return
            }

            let trimmedCardName = cardDetailsFormManager.cardholderNameText.trimmingCharacters(in: .whitespacesAndNewlines)
            let cardName = trimmedCardName.isEmpty ? nil : trimmedCardName

            let tokeniseCardDetailsReq = DataPaymentSources.CreatePaymentSourceTokenReq(
                type: "card",
                gatewayId: config.gatewayId,
                cardNumber: cardDetailsFormManager.cardNumberText.replacingOccurrences(of: " ", with: ""),
                cardName: cardName,
                expireMonth: String(expireMonth),
                expireYear: String(expireYear),
                cardCcv: cardDetailsFormManager.securityCodeText,
                storeCcv: config.storeSecurityCode,
                savedCardConsentAccepted: config.allowSaveCard != nil ? policyAccepted : nil)

            do {
                updateLoadingState(isLoading: true)
                let cardToken = try await paymentSourcesService.createToken(
                    tokeniseCardDetailsReq: tokeniseCardDetailsReq,
                    widgetAccessToken: config.accessToken)

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
        case .diners: Image("diners", bundle: Bundle.module)
        case .discover: Image("discover", bundle: Bundle.module)
        case .japcb: Image("jcb", bundle: Bundle.module)
        case .mastercard: Image("mastercard", bundle: Bundle.module)
        case .visa: Image("visa", bundle: Bundle.module)
        case .unionpay: Image("unionpay", bundle: Bundle.module)
        }
    }

    func isValidURLString(_ string: String?) -> Bool {
        guard let string else { return false }
        guard let url = URL(string: string) else { return false }
        guard let scheme = url.scheme,
              let host = url.host,
              !scheme.isEmpty,
              !host.isEmpty else { return false }

        return true
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
