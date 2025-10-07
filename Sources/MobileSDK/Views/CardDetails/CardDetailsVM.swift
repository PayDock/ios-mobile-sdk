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

    // MARK: - Properties

    private let completion: (Result<CardResult, CardDetailsError>) -> Void

    @Published var isLoading = false
    @Published var showLoaders = true
    @Published var policyAccepted = false
    var viewState: ViewState
    private weak var loadingDelegate: WidgetLoadingDelegate?

    var anyCancellable: AnyCancellable? // Required to allow updating the view from nested observable objects - SwiftUI quirk

    // MARK: - Initialisation

    init(cardService: CardService = CardServiceImpl(),
         viewState: ViewState,
         config: CardDetailsWidgetConfig,
         loadingDelegate: WidgetLoadingDelegate?,
         completion: @escaping (Result<CardResult, CardDetailsError>) -> Void) {
        self.cardService = cardService
        self.viewState = viewState
        self.config = config
        self.loadingDelegate = loadingDelegate
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
}
