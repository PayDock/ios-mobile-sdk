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

    var numberOfValidationErrors: Int {
        get { return cardDetailsFormManager.numberOfValidationFailures }
        set { cardDetailsFormManager.numberOfValidationFailures = newValue }
    }
    var firstTextFieldWithError: CardDetailsFocusable? {
        get { return cardDetailsFormManager.firstFieldWithError }
        set { cardDetailsFormManager.firstFieldWithError = newValue }
    }

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
        self.cardDetailsFormManager.securityCodePlaceholder = appearance.cardSecurityTextField.placeholderText ?? ""

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

    func ctaButtonTapped() -> Bool {
        guard cardDetailsFormManager.validateForm() else {
            handleTokenisationTapAnalytics(isFormValid: false)
            return false
        }

        handleTokenisationTapAnalytics(isFormValid: true)
        tokeniseCardDetails()

        return true
    }

    func tokeniseCardDetails() {
        // Transition to loading synchronously (before dispatching the Task), so a second call
        // arriving before the Task body has actually started still sees isLoading == true rather
        // than racing it — this is what makes callers' own re-entrancy guards durable.
        guard !isLoading else { return }
        updateLoadingState(isLoading: true)

        Task {
            guard let expireMonth = self.cardDetailsFormManager.expiryDateText.split(separator: "/").first,
                  let expireYear = self.cardDetailsFormManager.expiryDateText.split(separator: "/").last else {
                updateLoadingState(isLoading: false)
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
        if config.activePrimaryButton {
            return false
        }

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

    // MARK: - Accessibility Helpers

    /// Whether the expiry/security-code row should stack vertically. Pure function of the Dynamic
    /// Type size so it can be unit-tested (the view passes its `@Environment(\.dynamicTypeSize)`).
    /// Standard sizes lay out horizontally; accessibility sizes (AX1–AX5) stack vertically.
    func shouldAlignVertically(for size: DynamicTypeSize) -> Bool {
        switch size {
        case .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge: return false
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5: return true
        @unknown default: return false
        }
    }

    /// The VoiceOver announcement for the number of validation errors after a failed submit.
    /// Returns `nil` when there are no errors (nothing to announce).
    func errorCountAnnouncement(_ count: Int) -> String? {
        AccessibilityAnnouncer.errorCountMessage(count)
    }

    /// The VoiceOver label describing the supported card schemes shown above the form, e.g.
    /// "Supported card schemes: Visa, Mastercard, American Express". Ordered by preferred order.
    func supportedSchemesAccessibilityLabel(for schemes: Set<CardScheme>) -> String {
        "Supported card schemes: " +
            CardScheme.sortedArray(from: schemes)
                .map(\.voiceoverName)
                .joined(separator: ", ")
    }

    // MARK: - Analytics Handling

    func handleTokenisationTapAnalytics(isFormValid: Bool) {
        let formState = isFormValid ? WidgetEventFormState.valid : WidgetEventFormState.invalid
        let event = WidgetEvent(
            type: .button,
            properties: .button(
                WidgetEventButtonProperties(
                    name: "TokenisationButton",
                    action: .click,
                    text: appearance.actionButton.text,
                    formState: formState
                )
            )
        )
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
