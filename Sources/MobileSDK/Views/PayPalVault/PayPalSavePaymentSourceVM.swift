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
        SdkTask.run(widget: .payPalSavePaymentSource) { [self] in
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
                // An outcome: SdkTelemetry drops it (R_05); the call keeps one per delivery (R_06).
                SdkTelemetry.reportSdkError(PayPalVaultError.userCancelled, widget: .payPalSavePaymentSource)
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
            let failure = PayPalVaultError.getPayPalClientId(error: errorResponse)
            SdkTelemetry.reportSdkError(failure, widget: .payPalSavePaymentSource)
            completion(.failure(failure))
            updateLoadingState(isLoading: false)
        } catch {
            let failure = PayPalVaultError.unknownError(error as? RequestError)
            SdkTelemetry.reportSdkError(failure, widget: .payPalSavePaymentSource)
            completion(.failure(failure))
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
            let failure = PayPalVaultError.createSetupToken(error: errorResponse)
            SdkTelemetry.reportSdkError(failure, widget: .payPalSavePaymentSource)
            completion(.failure(failure))
            updateLoadingState(isLoading: false)
        } catch {
            let failure = PayPalVaultError.unknownError(error as? RequestError)
            SdkTelemetry.reportSdkError(failure, widget: .payPalSavePaymentSource)
            completion(.failure(failure))
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
            let failure = PayPalVaultError.createPaymentToken(error: errorResponse)
            SdkTelemetry.reportSdkError(failure, widget: .payPalSavePaymentSource)
            completion(.failure(failure))
            updateLoadingState(isLoading: false)

        } catch {
            let failure = PayPalVaultError.unknownError(error as? RequestError)
            SdkTelemetry.reportSdkError(failure, widget: .payPalSavePaymentSource)
            completion(.failure(failure))
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
            // An outcome: SdkTelemetry drops it (R_05); the call keeps one per delivery (R_06).
            SdkTelemetry.reportSdkError(PayPalVaultError.userCancelled, widget: .payPalSavePaymentSource)
            completion(.failure(.userCancelled))
        } else if let coreError = error as? CoreSDKError {
            let errorDescription = coreError.errorDescription ?? ""
            let failure = PayPalVaultError.sdkException(description: errorDescription)
            SdkTelemetry.reportSdkError(failure, widget: .payPalSavePaymentSource)
            completion(.failure(failure))
        } else {
            let failure = PayPalVaultError.unknownError(error as? RequestError)
            SdkTelemetry.reportSdkError(failure, widget: .payPalSavePaymentSource)
            completion(.failure(failure))
        }

        updateLoadingState(isLoading: false)
    }

    // MARK: - Analytics Handling

    func handleButtonTapAnalytics() {
        let event = WidgetEvent(type: .button, properties: .button(WidgetEventButtonProperties(name: "PayPalVaultButton", action: .click)))
        eventDelegate?.widgetEvent(event: event)
    }
}
