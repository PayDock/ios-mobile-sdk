//
//  PayPalVM.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import NetworkingLib
import PayPalWebPayments
import CorePayments
import DataGateways
import DataCharges

@MainActor
class PayPalVM: ObservableObject {

    // MARK: - Dependencies

    private let chargesService: DataCharges.ChargesService
    private let gatewayService: DataGateways.GatewayService
    private let config: PayPalWidgetConfig

    // MARK: - Properties

    private let tokenRequest: (_ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) -> Void

    @Published var isLoading = false
    @Published var showLoaders = true
    var viewState: ViewState
    private var token = ""
    /// The open payment attempt (D24), from the button tap until the checkout's end.
    var payment: PaymentAttempt?

    // MARK: - Handlers

    private var completion: (Result<ChargeResponse, PayPalError>) -> Void
    private weak var loadingDelegate: WidgetLoadingDelegate?
    private weak var eventDelegate: WidgetEventDelegate?

    // MARK: - Initialisation

    init(config: PayPalWidgetConfig,
         viewState: ViewState,
         tokenRequest: @escaping (_ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) -> Void,
         chargesService: DataCharges.ChargesService = DataCharges.ChargesServiceImpl(),
         gatewayService: DataGateways.GatewayService = DataGateways.GatewayServiceImpl(),
         loadingDelegate: WidgetLoadingDelegate?,
         eventDelegate: WidgetEventDelegate?,
         completion: @escaping (Result<ChargeResponse, PayPalError>) -> Void) {
        self.config = config
        self.viewState = viewState
        self.tokenRequest = tokenRequest
        self.chargesService = chargesService
        self.gatewayService = gatewayService
        self.loadingDelegate = loadingDelegate
        self.eventDelegate = eventDelegate
        self.completion = completion

        if loadingDelegate != nil {
            showLoaders = false
        }
    }

    // MARK: - Prepare for checkout

    func handleButtonTap() {
        payment = SdkTelemetry.startPayment(.payPal)
        updateLoadingState(isLoading: true)
        tokenRequest { [weak self] result in
            SdkTask.run(widget: .payPal) {
                switch result {
                case .success(let response):
                    self?.token = response.token
                    self?.initializePayPalSDK()

                case .failure(let failure):
                    self?.updateLoadingState(isLoading: false)
                    let tokenFailure = PayPalError.initialisingWalletToken(reason: failure.customMessage)
                    SdkTelemetry.reportSdkError(tokenFailure, widget: .payPal)
                    if let self { SdkTelemetry.finishPayment(&self.payment, .failed(tokenFailure)) }
                    self?.completion(.failure(tokenFailure))
                }
            }
        }
    }

    func initializePayPalSDK() {
        SdkTask.run(widget: .payPal) { [self] in
            guard let clientId = await getClientId(),
                  let orderId = await getOrderId(token: token) else {
                updateLoadingState(isLoading: false)
                return
            }

            let coreConfig = CoreConfig(clientID: clientId, environment: Constants.payPalEnvironment)
            let payPalClient = PayPalWebCheckoutClient(config: coreConfig)
            let payPalWebRequest = PayPalWebCheckoutRequest(orderID: orderId, fundingSource: config.fundingSource)

            updateLoadingState(isLoading: false)

            // Check if app is in foreground before proceeding
            guard UIApplication.shared.applicationState == .active else {
                // An outcome: SdkTelemetry drops it (R_05); the call keeps one per delivery (R_06).
                SdkTelemetry.reportSdkError(PayPalError.userCancelled, widget: .payPal)
                SdkTelemetry.finishPayment(&payment, .cancelled)
                completion(.failure(.userCancelled))
                return
            }

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
            return try await chargesService.getPayPalCallback(widgetAccessToken: token, requestShipping: config.requestShipping)

        } catch let RequestError.requestError(errorResponse: errorResponse) {
            updateLoadingState(isLoading: false)
            let failure = PayPalError.errorFetchingOrderId(error: errorResponse)
            SdkTelemetry.reportSdkError(failure, widget: .payPal)
            SdkTelemetry.finishPayment(&payment, .failed(failure))
            self.completion(.failure(failure))

        } catch {
            updateLoadingState(isLoading: false)
            let failure = PayPalError.unknownError(error as? RequestError)
            SdkTelemetry.reportSdkError(failure, widget: .payPal)
            SdkTelemetry.finishPayment(&payment, .failed(failure))
            self.completion(.failure(failure))
        }
        return nil
    }

    func getClientId() async -> String? {
        updateLoadingState(isLoading: true)
        do {
            return try await gatewayService.getClientId(gatewayId: config.gatewayId, widgetAccessToken: config.accessToken)

        } catch let RequestError.requestError(errorResponse: errorResponse) {
            let failure = PayPalError.getPayPalClientId(error: errorResponse)
            SdkTelemetry.reportSdkError(failure, widget: .payPal)
            SdkTelemetry.finishPayment(&payment, .failed(failure))
            completion(.failure(failure))
            updateLoadingState(isLoading: false)

        } catch {
            let failure = PayPalError.unknownError(error as? RequestError)
            SdkTelemetry.reportSdkError(failure, widget: .payPal)
            SdkTelemetry.finishPayment(&payment, .failed(failure))
            completion(.failure(failure))
            updateLoadingState(isLoading: false)
        }
        return nil
    }

    // MARK: - Capture charge

    func capturePayPalPayment(paymentMethodId: String, payerId: String) {
        guard !token.isEmpty else {
            SdkTelemetry.reportSdkError(PayPalError.unknownError(nil), widget: .payPal)
            SdkTelemetry.finishPayment(&payment, .failed(PayPalError.unknownError(nil)))
            completion(.failure(.unknownError(nil)))
            updateLoadingState(isLoading: false)
            return
        }

        SdkTask.run(widget: .payPal) { [self] in
            do {
                let walletChargeData = try await chargesService.captureWalletCharge(
                    widgetAccessToken: token,
                    paymentMethodId: paymentMethodId,
                    refToken: nil)
                let chargeResponse = ChargeResponse(
                    status: walletChargeData.status,
                    amount: walletChargeData.amount,
                    currency: walletChargeData.currency
                )

                SdkTelemetry.finishPayment(&payment, .success)
                self.completion(.success(chargeResponse))
                updateLoadingState(isLoading: false)

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                let failure = PayPalError.errorCapturingCharge(error: errorResponse)
                SdkTelemetry.reportSdkError(failure, widget: .payPal)
                SdkTelemetry.finishPayment(&payment, .failed(failure))
                self.completion(.failure(failure))
                updateLoadingState(isLoading: false)

            } catch {
                let failure = PayPalError.unknownError(error as? RequestError)
                SdkTelemetry.reportSdkError(failure, widget: .payPal)
                SdkTelemetry.finishPayment(&payment, .failed(failure))
                self.completion(.failure(failure))
                updateLoadingState(isLoading: false)
            }
        }
    }

    // MARK: - Outcome handling

    private func handlePayPalSuccess(result: PayPalWebCheckoutResult) {
        capturePayPalPayment(paymentMethodId: result.orderID, payerId: result.payerID)
    }

    func handlePayPalError(_ error: Error) {
        if PayPalWebPayments.PayPalError.isCheckoutCanceled(error) {
            // An outcome: SdkTelemetry drops it (R_05); the call keeps one per delivery (R_06).
            SdkTelemetry.reportSdkError(PayPalError.userCancelled, widget: .payPal)
            SdkTelemetry.finishPayment(&payment, .cancelled)
            completion(.failure(.userCancelled))
        } else if let coreError = error as? CoreSDKError {
            let errorDescription = coreError.errorDescription ?? ""
            let failure = PayPalError.sdkException(description: errorDescription)
            SdkTelemetry.reportSdkError(failure, widget: .payPal)
            SdkTelemetry.finishPayment(&payment, .failed(failure))
            completion(.failure(failure))
        } else {
            let failure = PayPalError.unknownError(error as? RequestError)
            SdkTelemetry.reportSdkError(failure, widget: .payPal)
            SdkTelemetry.finishPayment(&payment, .failed(failure))
            completion(.failure(failure))
        }

        updateLoadingState(isLoading: false)
    }

    // MARK: - Analytics Handling

    func handleButtonTapAnalytics() {
        let event = WidgetEvent(
            type: .button,
            properties: .button(WidgetEventButtonProperties(name: "PayPalCheckoutButton", action: .click)))
        eventDelegate?.widgetEvent(event: event)
    }

    // MARK: - Test Helpers

    #if DEBUG
    func test_setToken(_ token: String) {
        self.token = token
    }
    #endif

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
