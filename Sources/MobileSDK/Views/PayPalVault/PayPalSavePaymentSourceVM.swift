//
//  PayPalSavePaymentSourceVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 16.10.2024..
//

import SwiftUI
import NetworkingLib
import CorePayments
import PayPalWebPayments
import DataGateways
import DataPaymentSources

@MainActor
class PayPalSavePaymentSourceVM: ObservableObject {

    // MARK: - Dependencies

    let config: PayPalVaultConfig
    private let paymentSourcesService: DataPaymentSources.PaymentSourcesService
    private let gatewayService: DataGateways.GatewayService

    // MARK: - Properties

    @Published var actionText: String = ""
    @Published var isLoading = false
    @Published var showLoaders = true
    var viewState: ViewState
    private weak var loadingDelegate: WidgetLoadingDelegate?
    private weak var eventDelegate: WidgetEventDelegate?

    // MARK: - Handlers

    private var completion: (Result<PayPalVaultResult, PayPalVaultError>) -> Void

    // MARK: - Initialisation

    init(viewState: ViewState,
         config: PayPalVaultConfig,
         paymentSourcesService: DataPaymentSources.PaymentSourcesService = DataPaymentSources.PaymentSourcesServiceImpl(),
         gatewayService: DataGateways.GatewayService = DataGateways.GatewayServiceImpl(),
         loadingDelegate: WidgetLoadingDelegate?,
         eventDelegate: WidgetEventDelegate?,
         completion: @escaping (Result<PayPalVaultResult, PayPalVaultError>) -> Void) {
        self.viewState = viewState
        self.config = config
        self.paymentSourcesService = paymentSourcesService
        self.gatewayService = gatewayService
        self.loadingDelegate = loadingDelegate
        self.eventDelegate = eventDelegate
        self.completion = completion

        if loadingDelegate != nil {
            showLoaders = false
        }
    }

    // MARK: - PayPal Initialization

    func initializePayPalSDK() {
        Task {
            guard let clientId = await getClientId(),
                  let setupTokenData = await getSetupTokenData() else {
                updateLoadingState(isLoading: false)
                return
            }

            let vaultRequest = PayPalVaultRequest(setupTokenID: setupTokenData.setupToken)
            let environment = Constants.payPalEnvironment
            let payPalConfig = CoreConfig(clientID: clientId, environment: environment)
            let payPalClient = PayPalWebCheckoutClient(config: payPalConfig)

            updateLoadingState(isLoading: false)

            // Check if app is in foreground before proceeding
            guard UIApplication.shared.applicationState == .active else {
                completion(.failure(.userCancelled))
                return
            }

            do {
                let vaultResult = try await payPalClient.vault(vaultRequest)
                await createPaymentToken(setupToken: vaultResult.tokenID)
            } catch {
                handleVaultError(error)
            }
        }
    }

    func getClientId() async -> String? {
        updateLoadingState(isLoading: true)
        do {
            return try await gatewayService.getClientId(gatewayId: config.gatewayId, widgetAccessToken: config.accessToken)
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.getPayPalClientId(error: errorResponse)))
            updateLoadingState(isLoading: false)
        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
            updateLoadingState(isLoading: false)
        }
        return nil
    }

    func getSetupTokenData() async -> SetupTokenData? {
        updateLoadingState(isLoading: true)
        do {
            let request = DataPaymentSources.CreatePayPalVaultSetupTokenReq(gatewayId: config.gatewayId)
            return try await paymentSourcesService.createSetupTokenData(req: request, widgetAccessToken: config.accessToken)
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.createSetupToken(error: errorResponse)))
            updateLoadingState(isLoading: false)
        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
            updateLoadingState(isLoading: false)
        }
        return nil
    }

    func createPaymentToken(setupToken: String) async {
        updateLoadingState(isLoading: true)
        do {
            let request = DataPaymentSources.CreatePayPalVaultPaymentTokenReq(gatewayId: config.gatewayId)
            let tokenData = try await paymentSourcesService.createPaymentToken(
                request: request,
                setupToken: setupToken,
                widgetAccessToken: config.accessToken)

            updateLoadingState(isLoading: false)
            completion(.success(PayPalVaultResult(token: tokenData.token, email: tokenData.email)))

        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.createPaymentToken(error: errorResponse)))
            updateLoadingState(isLoading: false)

        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
            updateLoadingState(isLoading: false)
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

        self.isLoading = isLoading
        self.viewState.isDisabled = isLoading
    }

    // MARK: - Error Handling

    private func handleVaultError(_ error: Error) {
        if PayPalWebPayments.PayPalError.isVaultCanceled(error) {
            completion(.failure(.userCancelled))
        } else if let coreError = error as? CoreSDKError {
            let errorDescription = coreError.errorDescription ?? ""
            completion(.failure(.sdkException(description: errorDescription)))
        } else {
            completion(.failure(.unknownError(error as? RequestError)))
        }

        updateLoadingState(isLoading: false)
    }

    // MARK: - Analytics Handling

    func handleButtonTapAnalytics() {
        let event = WidgetEvent(type: .button, properties: .button(WidgetEventButtonProperties(name: "PayPalVaultButton", action: .click)))
        eventDelegate?.widgetEvent(event: event)
    }
}
