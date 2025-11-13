//
//  ColesPayVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 11.01.2024..
//

import SwiftUI
import NetworkingLib

@MainActor
class ColesPayVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    private let tokenRequest: (_ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) -> Void
    private var colesPayUrl: URL?
    let config: ColesPayConfig
    @Published var showWebView = false
    @Published var isLoading = false
    @Published var showLoaders = true
    @Published var showCancelConfirmation = false
    var viewState: ViewState
    private var token = ""
    private(set) var colesPayOrderId = ""

    // MARK: - Handlers

    private var completion: (Result<String, ColesPayError>) -> Void
    private weak var loadingDelegate: WidgetLoadingDelegate?
    private weak var eventDelegate: WidgetEventDelegate?

    // MARK: - Initialisation

    init(config: ColesPayConfig,
         tokenRequest: @escaping (_ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) -> Void,
         walletService: WalletService = WalletServiceImpl(),
         viewState: ViewState,
         loadingDelegate: WidgetLoadingDelegate?,
         eventDelegate: WidgetEventDelegate?,
         completion: @escaping (Result<String, ColesPayError>) -> Void) {
        self.config = config
        self.tokenRequest = tokenRequest
        self.walletService = walletService
        self.viewState = viewState
        self.loadingDelegate = loadingDelegate
        self.eventDelegate = eventDelegate
        self.completion = completion

        if loadingDelegate != nil {
            showLoaders = false
        }
    }

    func getColesPayURL(token: String) {
        Task {
            do {
                updateLoadingState(isLoading: true)
                let colesPayOrderId = try await walletService.getColesPayCallback(token: token)
                self.isLoading = false
                self.colesPayOrderId = colesPayOrderId
                self.showWebView = true

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                self.updateLoadingState(isLoading: false)
                self.showWebView = false
                self.completion(.failure(.errorFetchingColesPayOrder(error: errorResponse)))

            } catch {
                updateLoadingState(isLoading: false)
                self.showWebView = false
                self.completion(.failure(.unknownError(error as? RequestError)))
            }
        }
    }

    func handleButtonTap() {
        updateLoadingState(isLoading: true)
        tokenRequest { [weak self] result in
            switch result {
            case .success(let response):
                Task { @MainActor in
                    self?.token = response.token
                    self?.getColesPayURL(token: response.token)
                }

            case .failure(let failure):
                Task { @MainActor in
                    self?.updateLoadingState(isLoading: false)
                    self?.showWebView = false
                    self?.completion(.failure(.initialisingWalletToken(reason: failure.customMessage)))
                }
            }
        }
    }

    func handleSuccess() {
        updateLoadingState(isLoading: false)
        showWebView = false
        completion(.success((colesPayOrderId)))
    }

    func handleFailure(error: ColesPayError) {
        updateLoadingState(isLoading: false)
        showWebView = false
        completion(.failure(error))
    }

    func handleSheetCancellation() {
        updateLoadingState(isLoading: false)
        completion(.failure(.transactionCanceled))
    }

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

    // MARK: - Analytics Handling

    func handleaButtonTapAnalytics() {
        let event = WidgetEvent(
            type: .button,
            properties: .button(WidgetEventButtonProperties(name: "ColesPayCheckoutButton", action: .click)))
        eventDelegate?.widgetEvent(event: event)
    }
}
