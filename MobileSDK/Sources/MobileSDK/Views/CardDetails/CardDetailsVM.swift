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
    private let accessToken: String

    // MARK: - Properties

    private let gatewayId: String?
    let actionText: String
    let showCardTitle: Bool
    let collectCardholderName: Bool
    let allowSaveCard: SaveCardConfig?
    private let completion: (Result<CardResult, CardDetailsError>) -> Void

    @Published var isLoading = false
    @Published var showLoaders = true
    @Published var policyAccepted = false
<<<<<<< HEAD
    var options: WidgetOptions
=======
    var viewState: ViewState
>>>>>>> main
    private weak var loadingDelegate: WidgetLoadingDelegate?

    var anyCancellable: AnyCancellable? = nil // Required to allow updating the view from nested observable objects - SwiftUI quirk

    // MARK: - Initialisation

    init(cardService: CardService = CardServiceImpl(),
<<<<<<< HEAD
         options: WidgetOptions,
=======
         viewState: ViewState,
>>>>>>> main
         gatewayId: String?,
         accessToken: String,
         actionText: String,
         showCardTitle: Bool,
         collectCardholderName: Bool,
         allowSaveCard: SaveCardConfig?,
         loadingDelegate: WidgetLoadingDelegate?,
         completion: @escaping (Result<CardResult, CardDetailsError>) -> Void) {
        self.cardService = cardService
<<<<<<< HEAD
        self.options = options
=======
        self.viewState = viewState
>>>>>>> main
        self.gatewayId = gatewayId
        self.accessToken = accessToken
        self.actionText = actionText
        self.showCardTitle = showCardTitle
        self.collectCardholderName = collectCardholderName
        self.allowSaveCard = allowSaveCard
        self.loadingDelegate = loadingDelegate
        self.completion = completion
        
        self.cardDetailsFormManager = CardDetailsFormManager(shouldValidateCardholderName: collectCardholderName)
        
        if (loadingDelegate != nil) {
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
            
            let cardName = cardDetailsFormManager.cardholderNameText.isEmpty ? nil : cardDetailsFormManager.cardholderNameText

            let tokeniseCardDetailsReq = TokeniseCardDetailsReq(
                gatewayId: gatewayId,
                cardName: cardName,
                cardNumber: cardDetailsFormManager.cardNumberText.replacingOccurrences(of: " ", with: ""),
                expireMonth: String(expireMonth),
                expireYear: String(expireYear),
                cardCcv: cardDetailsFormManager.securityCodeText)

            do {
                updateLoadingState(isLoading: true)
                let cardToken = try await cardService.createToken(tokeniseCardDetailsReq: tokeniseCardDetailsReq, accessToken: accessToken)
                updateLoadingState(isLoading: false)
                completion(.success(createResult(token: cardToken)))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                updateLoadingState(isLoading: false)
                completion(.failure(.errorTokenisingCard(error: errorResponse)))
            } catch {
                updateLoadingState(isLoading: false)
                completion(.failure(.unknownError))
            }
        }
    }
    
    // MARK: - Validation
    
    func isActionButtonDisabled() -> Bool {
<<<<<<< HEAD
        return options.isDisabled || !cardDetailsFormManager.isFormValid()
=======
        return viewState.isDisabled || !cardDetailsFormManager.isFormValid()
>>>>>>> main
    }
    
    // MARK: - State Management
    
    func updateLoadingState(isLoading: Bool) {
        if (loadingDelegate != nil) {
            if (isLoading) {
                loadingDelegate?.loadingDidStart()
            } else {
                loadingDelegate?.loadingDidFinish()
            }
        }
        
        self.isLoading = isLoading
<<<<<<< HEAD
        options.isDisabled = isLoading
=======
        viewState.isDisabled = isLoading
>>>>>>> main
    }

    private func createResult(token: String) -> CardResult {
        if let _ = allowSaveCard {
            return CardResult(token: token, saveCard: policyAccepted)
        } else {
            return CardResult(token: token, saveCard: nil)
        }
    }
}
