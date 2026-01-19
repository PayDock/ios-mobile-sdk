//
//  ZipVM.swift
//  MobileSDK
//
//  Copyright © 2025 Paydock Ltd.

import SwiftUI
import NetworkingLib
import DataPaymentSources

@MainActor
class ZipVM: ObservableObject {

    // MARK: - Dependencies

    private let paymentSourcesService: DataPaymentSources.PaymentSourcesService

    // MARK: - Properties

    private let config: ZipConfig

    @Published var showWebView = false
    @Published var isLoading = false
    @Published var showLoaders = true
    @Published var showCancelConfirmation = false
    var viewState: ViewState
    var zipUrl: URL?
    private var checkoutToken: String?
    private var accessToken: String

    // MARK: - Handlers

    private var completion: (Result<String, ZipError>) -> Void
    private weak var loadingDelegate: WidgetLoadingDelegate?
    private weak var eventDelegate: WidgetEventDelegate?

    // MARK: - Initialisation

    init(viewState: ViewState,
         config: ZipConfig,
         paymentSourcesService: DataPaymentSources.PaymentSourcesService = DataPaymentSources.PaymentSourcesServiceImpl(),
         loadingDelegate: WidgetLoadingDelegate?,
         eventDelegate: WidgetEventDelegate?,
         completion: @escaping (Result<String, ZipError>) -> Void) {
        self.viewState = viewState
        self.config = config
        self.accessToken = config.token
        self.paymentSourcesService = paymentSourcesService
        self.loadingDelegate = loadingDelegate
        self.eventDelegate = eventDelegate
        self.completion = completion

        if loadingDelegate != nil {
            showLoaders = false
        }
    }

    func createZipCheckout() {
        Task {
            do {
                updateLoadingState(isLoading: true)
                let externalCheckoutReq = DataPaymentSources.CreateExternalCheckoutReq(
                    gatewayId: self.config.gatewayId,
                    meta: DataPaymentSources.ExternalCheckoutMeta(
                        firstName: self.config.shopper.firstName,
                        lastName: self.config.shopper.lastName,
                        email: self.config.shopper.email,
                        tokenize: true,
                        charge: DataPaymentSources.ExternalCheckoutCharge(
                            amount: Double(truncating: self.config.amount as NSNumber),
                            currency: self.config.currency,
                            billingAddress: self.config.billing.map { billing in
                                DataPaymentSources.ExternalBillingAddress(
                                    firstName: billing.firstName,
                                    lastName: billing.lastName,
                                    addressLine1: billing.line1,
                                    addressCity: billing.city,
                                    addressState: billing.state,
                                    addressCountry: billing.countryCode,
                                    addressPostcode: billing.postalCode
                                )
                            }
                        )
                    ),
                    successRedirectUrl: Constants.zipRedirectUrl,
                    errorRedirectUrl: Constants.zipRedirectUrl,
                    redirectUrl: Constants.zipRedirectUrl
                )
                let (link, checkoutToken) = try await paymentSourcesService.initialiseExternalCheckout(
                    widgetAccessToken: self.accessToken,
                    request: externalCheckoutReq
                )

                // Store checkout token for later use
                self.checkoutToken = checkoutToken
                self.zipUrl = URL(string: link)

                updateLoadingState(isLoading: false)

                withAnimation {
                    self.showWebView = true
                }

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                updateLoadingState(isLoading: false)
                self.showWebView = false
                self.completion(.failure(.errorFetchingZipUrl(error: errorResponse)))

            } catch {
                updateLoadingState(isLoading: false)
                self.showWebView = false
                self.completion(.failure(.unknownError))
            }
        }
    }

    func handleZipConfirmation(callbackData: ZipCallbackData) {
        // On success, create a payment source token (matching web implementation)
        guard let checkoutToken = self.checkoutToken else {
            self.showWebView = false
            self.completion(.failure(.unknownError))
            return
        }

        Task {
            do {
                updateLoadingState(isLoading: true)

                // Create payment source token from checkout token
                let paymentSourceToken = try await paymentSourcesService.createPaymentSourceToken(
                    checkoutToken: checkoutToken,
                    gatewayId: self.config.gatewayId,
                    widgetAccessToken: self.accessToken
                )

                updateLoadingState(isLoading: false)
                self.showWebView = false
                self.completion(.success(paymentSourceToken))

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                updateLoadingState(isLoading: false)
                self.showWebView = false
                self.completion(.failure(.errorCapturingCharge(error: errorResponse)))

            } catch {
                updateLoadingState(isLoading: false)
                self.showWebView = false
                self.completion(.failure(.unknownError))
            }
        }
    }

    func handleButtonTap() {
        createZipCheckout()
    }

    func handleWebViewFailure(_ error: ZipError) {
        showWebView = false
        completion(.failure(error))
    }

    func handleSheetCancellation() {
        // Manual cancellation doesn't have a checkoutId since it happens before Zip returns
        completion(.failure(.transactionCanceled(checkoutId: nil)))
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

    func handleZipButtonTapAnalytics() {
        let event = WidgetEvent(
            type: .button,
            properties: .button(WidgetEventButtonProperties(name: "ZipCheckoutButton", action: .click)))
        eventDelegate?.widgetEvent(event: event)
    }
}
