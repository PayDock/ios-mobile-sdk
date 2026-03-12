//
//  ZipVM.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import NetworkingLib
import DataPaymentSources

@MainActor
class ZipVM: ObservableObject {

    // MARK: - Dependencies

    private let paymentSourcesService: DataPaymentSources.PaymentSourcesService

    // MARK: - Properties

    private let config: ZipWidgetConfig

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
         config: ZipWidgetConfig,
         paymentSourcesService: DataPaymentSources.PaymentSourcesService = DataPaymentSources.PaymentSourcesServiceImpl(),
         loadingDelegate: WidgetLoadingDelegate?,
         eventDelegate: WidgetEventDelegate?,
         completion: @escaping (Result<String, ZipError>) -> Void) {
        self.viewState = viewState
        self.config = config
        self.accessToken = config.accessToken
        self.paymentSourcesService = paymentSourcesService
        self.loadingDelegate = loadingDelegate
        self.eventDelegate = eventDelegate
        self.completion = completion

        if loadingDelegate != nil {
            showLoaders = false
        }
    }

    // swiftlint:disable:next function_body_length
    func createZipCheckout() {
        Task {
            do {
                updateLoadingState(isLoading: true)
                let externalCheckoutReq = DataPaymentSources.CreateExternalCheckoutReq(
                    gatewayId: self.config.gatewayId,
                    meta: DataPaymentSources.ExternalCheckoutMeta(
                        firstName: self.config.firstName,
                        lastName: self.config.lastName,
                        email: self.config.email,
                        phone: self.config.phone,
                        gender: self.config.gender,
                        dateOfBirth: self.config.dateOfBirth,
                        tokenize: self.config.tokenize,
                        charge: DataPaymentSources.ExternalCheckoutCharge(
                            amount: self.config.amount,
                            currency: self.config.currency,
                            shippingType: self.config.shippingType,
                            billingAddress: self.config.billing.map { billing in
                                DataPaymentSources.ExternalBillingAddress(
                                    firstName: billing.firstName,
                                    lastName: billing.lastName,
                                    addressLine1: billing.line1,
                                    addressLine2: billing.line2,
                                    addressCity: billing.city,
                                    addressState: billing.state,
                                    addressCountry: billing.country,
                                    addressPostcode: billing.postcode
                                )
                            },
                            shippingAddress: self.config.shipping.map { shipping in
                                DataPaymentSources.ExternalBillingAddress(
                                    firstName: shipping.firstName,
                                    lastName: shipping.lastName,
                                    addressLine1: shipping.line1,
                                    addressLine2: shipping.line2,
                                    addressCity: shipping.city,
                                    addressState: shipping.state,
                                    addressCountry: shipping.country,
                                    addressPostcode: shipping.postcode
                                )
                            },
                            items: self.config.items?.map { item in
                                DataPaymentSources.ExternalCheckoutItem(
                                    name: item.name,
                                    amount: item.amount,
                                    quantity: item.quantity,
                                    reference: item.reference
                                )
                            }
                        ),
                        statistics: self.config.statistics.map { stats in
                            DataPaymentSources.ExternalCheckoutStatistics(
                                accountCreated: stats.accountCreated,
                                salesTotalNumber: stats.salesTotalNumber,
                                salesTotalAmount: stats.salesTotalAmount,
                                salesAvgValue: stats.salesAvgValue,
                                salesMaxValue: stats.salesMaxValue,
                                refundsTotalAmount: stats.refundsTotalAmount,
                                previousChargeback: stats.previousChargeback,
                                currency: stats.currency,
                                lastLogin: stats.lastLogin
                            )
                        }
                    ),
                    successRedirectUrl: Constants.zipRedirectUrl,
                    errorRedirectUrl: Constants.zipRedirectUrl,
                    redirectUrl: Constants.zipRedirectUrl
                )
                let (link, checkoutToken) = try await paymentSourcesService.initialiseExternalCheckout(
                    widgetAccessToken: self.accessToken,
                    request: externalCheckoutReq
                )

                guard let url = URL(string: link), isValidWebViewUrl(url) else {
                    updateLoadingState(isLoading: false)
                    self.showWebView = false
                    self.completion(.failure(.invalidCheckoutUrl))
                    return
                }

                // Store checkout token for later use
                self.checkoutToken = checkoutToken
                self.zipUrl = url

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
                self.completion(.failure(.unknownError(error as? RequestError)))
            }
        }
    }

    func handleZipConfirmation(callbackData: ZipCallbackData) {
        // On success, create a payment source token (matching web implementation)
        guard let checkoutToken = self.checkoutToken else {
            self.showWebView = false
            self.completion(.failure(.unknownError(nil)))
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
                self.completion(.failure(.unknownError(error as? RequestError)))
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

    // MARK: - Private Helpers

    /// Validates that the URL has an http or https scheme.
    /// This catches malformed URLs like "httpsandbox.zip.co/..." where the scheme separator is missing.
    private func isValidWebViewUrl(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased() else { return false }
        return scheme == "http" || scheme == "https"
    }
}
