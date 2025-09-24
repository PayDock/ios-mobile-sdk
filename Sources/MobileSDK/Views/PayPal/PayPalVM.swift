//
//  PayPalVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.10.2023..
//

import SwiftUI
import NetworkingLib
import PayPalWebPayments
import CorePayments

@MainActor
class PayPalVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService
    private let payPalVaultService: PayPalVaultService
    private let config: PayPalWidgetConfig

    // MARK: - Properties

    private let tokenRequest: (_ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) -> Void

    @Published var isLoading = false
    @Published var showLoaders = true
    var viewState: ViewState
    private var token = ""

    // MARK: - Handlers

    private var completion: (Result<ChargeResponse, PayPalError>) -> Void
    private weak var loadingDelegate: WidgetLoadingDelegate?

    // MARK: - Initialisation

    init(config: PayPalWidgetConfig,
         viewState: ViewState,
         tokenRequest: @escaping (_ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) -> Void,
         walletService: WalletService = WalletServiceImpl(),
         payPalVaultService: PayPalVaultService = PayPalVaultServiceImpl(),
         loadingDelegate: WidgetLoadingDelegate?,
         completion: @escaping (Result<ChargeResponse, PayPalError>) -> Void) {
        self.config = config
        self.viewState = viewState
        self.tokenRequest = tokenRequest
        self.walletService = walletService
        self.payPalVaultService = payPalVaultService
        self.loadingDelegate = loadingDelegate
        self.completion = completion

        if loadingDelegate != nil {
            showLoaders = false
        }
    }

    // MARK: - Prepare for checkout

    func handleButtonTap() {
        updateLoadingState(isLoading: true)
        tokenRequest { [weak self] result in
            switch result {
            case .success(let response):
                self?.token = response.token
                self?.initializePayPalSDK()

            case .failure(let failure):
                self?.updateLoadingState(isLoading: false)
                self?.completion(.failure(.initialisingWalletToken(reason: failure.customMessage)))
            }
        }
    }

    func initializePayPalSDK() {
        Task {
            guard let clientId = await getClientId(),
                  let orderId = await getOrderId(token: token) else {
                updateLoadingState(isLoading: false)
                return
            }

            let coreConfig = CoreConfig(clientID: clientId, environment: Constants.payPalEnvironment)
            let payPalClient = PayPalWebCheckoutClient(config: coreConfig)
            let payPalWebRequest = PayPalWebCheckoutRequest(orderID: orderId, fundingSource: config.fundingSource)

            updateLoadingState(isLoading: false)

            payPalClient.start(request: payPalWebRequest) { [weak self] result in
                guard let self else { return }
                updateLoadingState(isLoading: true)
                switch result {
                case .success(let checkoutResult):
                    self.handlePayPalSuccess(result: checkoutResult)
                case .failure(let error):
                    self.handlePayPalError(error)
                }
            }
        }
    }

    func getOrderId(token: String) async -> String? {
        updateLoadingState(isLoading: true)
        do {
            return try await walletService.getCallback(token: token, shipping: false)

        } catch let RequestError.requestError(errorResponse: errorResponse) {
            updateLoadingState(isLoading: false)
            self.completion(.failure(.errorFetchingOrderId(error: errorResponse)))

        } catch {
            updateLoadingState(isLoading: false)
            self.completion(.failure(.unknownError(error as? RequestError)))
        }
        return nil
    }

    func getClientId() async -> String? {
        updateLoadingState(isLoading: true)
        do {
            return try await payPalVaultService.getClientId(gatewayId: config.gatewayId, accessToken: config.accessToken)

        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.getPayPalClientId(error: errorResponse)))
            updateLoadingState(isLoading: false)

        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
            updateLoadingState(isLoading: false)
        }
        return nil
    }

    // MARK: - Capture charge

    func capturePayPalPayment(paymentMethodId: String, payerId: String) {
        guard !token.isEmpty else {
            completion(.failure(.unknownError(nil)))
            updateLoadingState(isLoading: false)
            return
        }

        Task {
            do {
                let charge = try await walletService.captureCharge(
                    token: token,
                    paymentMethodId: paymentMethodId,
                    payerId: payerId,
                    refToken: nil)

                self.completion(.success(charge))
                updateLoadingState(isLoading: false)

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                self.completion(.failure(.errorCapturingCharge(error: errorResponse)))
                updateLoadingState(isLoading: false)

            } catch {
                self.completion(.failure(.unknownError(error as? RequestError)))
                updateLoadingState(isLoading: false)
            }
        }
    }

    // MARK: - Outcome handling

    private func handlePayPalSuccess(result: PayPalWebCheckoutResult) {
        capturePayPalPayment(paymentMethodId: result.orderID, payerId: result.payerID)
    }

    private func handlePayPalError(_ error: Error) {
        if PayPalWebPayments.PayPalError.isCheckoutCanceled(error) {
            completion(.failure(.userCancelled))
        } else if let coreError = error as? CoreSDKError {
            let errorDescription = coreError.errorDescription ?? ""
            completion(.failure(.sdkException(description: errorDescription)))
        } else {
            completion(.failure(.unknownError(error as? RequestError)))
        }

        updateLoadingState(isLoading: false)
    }

    // MARK: - Helpers

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
}
