//
//  ColesPayVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 11.01.2024..
//

import SwiftUI
import NetworkingLib
import DataCharges

@MainActor
class ColesPayVM: ObservableObject {

    // MARK: - Dependencies

    private let chargesService: DataCharges.ChargesService

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
         chargesService: DataCharges.ChargesService = DataCharges.ChargesServiceImpl(),
         viewState: ViewState,
         loadingDelegate: WidgetLoadingDelegate?,
         eventDelegate: WidgetEventDelegate?,
         completion: @escaping (Result<String, ColesPayError>) -> Void) {
        self.config = config
        self.tokenRequest = tokenRequest
        self.chargesService = chargesService
        self.viewState = viewState
        self.loadingDelegate = loadingDelegate
        self.eventDelegate = eventDelegate
        self.completion = completion

        if loadingDelegate != nil {
            showLoaders = false
        }
    }

    func getColesPayURL(token: String) {
        SdkTask.run(widget: .colesPay) { [self] in
            do {
                updateLoadingState(isLoading: true)
                let colesPayOrderId = try await chargesService.getColesPayCallback(widgetAccessToken: token)
                self.isLoading = false
                self.colesPayOrderId = colesPayOrderId
                self.showWebView = true

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                self.updateLoadingState(isLoading: false)
                self.showWebView = false
                let failure = ColesPayError.errorFetchingColesPayOrder(error: errorResponse)
                SdkTelemetry.reportSdkError(failure, widget: .colesPay)
                self.completion(.failure(failure))

            } catch {
                updateLoadingState(isLoading: false)
                self.showWebView = false
                let failure = ColesPayError.unknownError(error as? RequestError)
                SdkTelemetry.reportSdkError(failure, widget: .colesPay)
                self.completion(.failure(failure))
            }
        }
    }

    func handleButtonTap() {
        updateLoadingState(isLoading: true)
        tokenRequest { [weak self] result in
            switch result {
            case .success(let response):
                SdkTask.run(widget: .colesPay) {
                    self?.token = response.token
                    self?.getColesPayURL(token: response.token)
                }

            case .failure(let failure):
                SdkTask.run(widget: .colesPay) {
                    self?.updateLoadingState(isLoading: false)
                    self?.showWebView = false
                    let tokenFailure = ColesPayError.initialisingWalletToken(reason: failure.customMessage)
                    SdkTelemetry.reportSdkError(tokenFailure, widget: .colesPay)
                    self?.completion(.failure(tokenFailure))
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
        SdkTelemetry.reportSdkError(error, widget: .colesPay)
        completion(.failure(error))
    }

    func handleSheetCancellation() {
        updateLoadingState(isLoading: false)
        // An outcome: SdkTelemetry drops it (R_05); the call keeps one per delivery (R_06).
        let failure = ColesPayError.transactionCanceled
        SdkTelemetry.reportSdkError(failure, widget: .colesPay)
        completion(.failure(failure))
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
