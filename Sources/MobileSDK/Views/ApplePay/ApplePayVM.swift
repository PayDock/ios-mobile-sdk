//
//  ApplePayVM.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import PassKit
import NetworkingLib
import DataPaymentSources

@MainActor
class ApplePayVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let paymentSourcesService: DataPaymentSources.PaymentSourcesService
    private let config: ApplePayWidgetConfig
    private let availabilityChecker: ApplePayAvailabilityChecking
    private let presenterFactory: PaymentAuthorizationPresenterFactory

    // MARK: - Properties

    private(set) var presenter: PaymentAuthorizationPresenting?
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var result: ApplePayResult?
    var error: ApplePayError?
    @Published var isProcessing = false

    private var isCompletionCalled = false
    private var pkPaymentCompletion: ((PKPaymentAuthorizationStatus) -> Void)?

    // MARK: - Handlers

    private weak var eventDelegate: WidgetEventDelegate?
    private let onShippingContactSelected: ((PKContact) -> PKPaymentRequestShippingContactUpdate)?
    private let onShippingMethodSelected: ((PKShippingMethod) -> PKPaymentRequestShippingMethodUpdate)?
    private let completion: (Result<ApplePayResult, ApplePayError>) -> Void

    // MARK: - Initialisation

    init(config: ApplePayWidgetConfig,
         eventDelegate: WidgetEventDelegate?,
         paymentSourcesService: DataPaymentSources.PaymentSourcesService = DataPaymentSources.PaymentSourcesServiceImpl(),
         availabilityChecker: ApplePayAvailabilityChecking = DefaultApplePayAvailabilityChecker(),
         presenterFactory: PaymentAuthorizationPresenterFactory = DefaultPaymentAuthorizationPresenterFactory(),
         onShippingContactSelected: ((PKContact) -> PKPaymentRequestShippingContactUpdate)? = nil,
         onShippingMethodSelected: ((PKShippingMethod) -> PKPaymentRequestShippingMethodUpdate)? = nil,
         completion: @escaping (Result<ApplePayResult, ApplePayError>) -> Void) {
        self.config = config
        self.eventDelegate = eventDelegate
        self.paymentSourcesService = paymentSourcesService
        self.availabilityChecker = availabilityChecker
        self.presenterFactory = presenterFactory
        self.onShippingContactSelected = onShippingContactSelected
        self.onShippingMethodSelected = onShippingMethodSelected
        self.completion = completion
    }

    func startPayment() {
        let presenter = presenterFactory.makePresenter(for: config.pkPaymentRequest)
        presenter.delegate = self
        self.presenter = presenter
        presenter.present(completion: { [weak self] success in
            if !success {
                Task { @MainActor in
                    self?.isProcessing = false
                    self?.error = .unableToPresentPaymentSheet
                    self?.callCompletion(.failure(.unableToPresentPaymentSheet))
                }
            }
        })
    }

    private func callCompletion(_ completion: (Result<ApplePayResult, ApplePayError>)) {
        guard !isCompletionCalled else { return }
        self.completion(completion)
        isCompletionCalled = true
    }

    // MARK: - Apple Pay Availability

    // Whether the widget should run its own availability checks (vs. trusting the integrator)
    var availabilityChecksEnabled: Bool {
        config.performAvailabilityChecks
    }

    // True when the hardware supports Apple Pay (regardless of enrolled cards)
    func deviceSupportsApplePay() -> Bool {
        availabilityChecker.deviceSupportsApplePay()
    }

    // Check to see if there cards already in wallet for default supported card schemes
    // (networks only — no capability filtering, so the setup-button decision isn't narrowed)
    func canMakePaymentsWithDefaultNetworks() -> Bool {
        availabilityChecker.canMakePaymentsWithDefaultNetworks()
    }

    // True when the hardware supports Apple Pay (regardless of enrolled cards)
    // "and" cards in wallet support set network and capabilities
    func canMakePaymentsWithConfiguredNetworksAndCapabilities() -> Bool {
        availabilityChecker.canMakePayments(for: config.pkPaymentRequest)
    }

    // Whether the device is capable but has no eligible cards enrolled
    func shouldShowSetupButton() -> Bool {
        if !deviceSupportsApplePay() {
            self.callCompletion(.failure(.notSupported))
            return false
        } else {
            self.callCompletion(.failure(.noSupportedCardsInWallet))
        }

        // Only show setup button if default schemes don't already
        // have a card setup so as not to confuse user opening
        // a wallet with already setup cards
        if !canMakePaymentsWithDefaultNetworks() &&
           config.showSetUpButtonWhenNoCardsEnrolled {
            return true
        }

        return false
    }

    // MARK: - OTT Token Creation

    /// Glue that extracts values from the (non-constructible-in-tests) `PKPayment` and delegates
    /// to the value-based `createOTTToken`. This is the only OTT step that touches PassKit types.
    private func createOTTToken(payment: PKPayment) async {
        let shipping = buildShipping(from: payment.shippingContact)
        let billing = buildBilling(from: payment.billingContact)
        // Card scheme from payment method network
        let cardScheme = payment.token.paymentMethod.network?.rawValue ?? ""
        // The ref_token is the JSON stringified payment data
        let refToken = String(data: payment.token.paymentData, encoding: .utf8) ?? ""

        await createOTTToken(
            shipping: shipping,
            billing: billing,
            cardScheme: cardScheme,
            refToken: refToken
        )
    }

    /// Builds the OTT payload (snake_case JSON, base64-encoded) from already-mapped values.
    /// Pure and free of PassKit types, so it can be unit-tested directly.
    /// - Returns: the base64 payload string, or `.payloadEncodingFailed` if encoding fails.
    func makeApplePayPayload(shipping: ApplePayOTTShipping?,
                             billing: ApplePayOTTBilling?,
                             cardScheme: String,
                             refToken: String) -> Result<String, ApplePayError> {
        let cardInfo = ApplePayOTTCardInfo(cardScheme: cardScheme)
        let payload = ApplePayOTTPayload(
            shipping: shipping,
            billing: billing,
            refToken: refToken,
            cardInfo: cardInfo
        )

        // Encode payload to JSON then base64
        let jsonEncoder = JSONEncoder()
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        guard let payloadData = try? jsonEncoder.encode(payload),
              let payloadString = String(data: payloadData, encoding: .utf8) else {
            return .failure(.payloadEncodingFailed)
        }
        return .success(Data(payloadString.utf8).base64EncodedString())
    }

    /// Encodes the payload, calls the token service and maps the outcome onto
    /// `result`/`error`/`paymentStatus`. Value-based (no PassKit types) so it is unit-testable
    /// via a mocked `PaymentSourcesService`.
    func createOTTToken(shipping: ApplePayOTTShipping?,
                        billing: ApplePayOTTBilling?,
                        cardScheme: String,
                        refToken: String) async {
        let cardInfo = ApplePayOTTCardInfo(cardScheme: cardScheme)

        let base64Payload: String
        switch makeApplePayPayload(shipping: shipping, billing: billing, cardScheme: cardScheme, refToken: refToken) {
        case .success(let payload):
            base64Payload = payload
        case .failure(let payloadError):
            self.error = payloadError
            self.paymentStatus = .failure
            self.pkPaymentCompletion?(.failure)
            return
        }

        let request = CreateApplePayTokenReq(
            serviceId: config.serviceId,
            payload: base64Payload
        )

        do {
            let token = try await paymentSourcesService.createApplePayToken(
                tokeniseApplePayReq: request,
                widgetAccessToken: config.accessToken
            )
            self.result = ApplePayResult(
                ottToken: token,
                cardInfo: cardInfo,
                shippingAddress: shipping,
                billingAddress: billing
            )
            self.paymentStatus = .success
            self.pkPaymentCompletion?(.success)
        } catch let requestError as RequestError {
            if case .requestError(let errorRes) = requestError {
                self.error = .errorCreatingToken(error: errorRes)
            } else {
                self.error = .unknownError(requestError)
            }
            self.paymentStatus = .failure
            self.pkPaymentCompletion?(.failure)
        } catch {
            // Preserve any RequestError so its diagnostic code survives (matches the sibling VMs).
            self.error = .unknownError(error as? RequestError)
            self.paymentStatus = .failure
            self.pkPaymentCompletion?(.failure)
        }
    }

    func buildShipping(from contact: PKContact?) -> ApplePayOTTShipping? {
        guard let contact = contact else { return nil }

        let postalAddress = contact.postalAddress

        return ApplePayOTTShipping(
            addressLine1: postalAddress?.street.components(separatedBy: "\n").first,
            addressLine2: postalAddress?.street.components(separatedBy: "\n").dropFirst().first,
            addressCountry: postalAddress?.isoCountryCode,
            addressCity: postalAddress?.city,
            addressPostcode: postalAddress?.postalCode,
            addressState: postalAddress?.state,
            contact: ApplePayOTTContact(
                firstName: contact.name?.givenName,
                lastName: contact.name?.familyName,
                email: contact.emailAddress,
                phone: contact.phoneNumber?.stringValue
            )
        )
    }

    func buildBilling(from contact: PKContact?) -> ApplePayOTTBilling? {
        guard let contact = contact else { return nil }

        let postalAddress = contact.postalAddress

        return ApplePayOTTBilling(
            addressLine1: postalAddress?.street.components(separatedBy: "\n").first,
            addressLine2: postalAddress?.street.components(separatedBy: "\n").dropFirst().first,
            addressCountry: postalAddress?.isoCountryCode,
            addressCity: postalAddress?.city,
            addressPostcode: postalAddress?.postalCode,
            addressState: postalAddress?.state
        )
    }

    // MARK: - Analytics Handling

    func handleApplePayTapAnalytics() {
        let event = WidgetEvent(
            type: .button,
            properties: .button(WidgetEventButtonProperties(name: "ApplePayCheckoutButton", action: .click)))
        eventDelegate?.widgetEvent(event: event)
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate

extension ApplePayVM: PKPaymentAuthorizationControllerDelegate {

    nonisolated func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                                    didAuthorizePayment payment: PKPayment,
                                                    completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        Task { @MainActor in
            self.pkPaymentCompletion = completion
            await self.createOTTToken(payment: payment)
        }
    }

    nonisolated func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            Task { @MainActor in
                self.finishAndComplete()
            }
        }
    }

    /// Selects the terminal completion based on the payment outcome. Extracted from the delegate
    /// callback (which requires a system-dismissed controller) so it can be unit-tested directly.
    @MainActor
    func finishAndComplete() {
        if paymentStatus == .success, let result = result {
            callCompletion(.success(result))
        } else {
            callCompletion(.failure(error ?? .userCanceledPayment))
        }
    }

    nonisolated func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                                    didSelectShippingContact contact: PKContact,
                                                    handler: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        Task { @MainActor in
            if let update = self.onShippingContactSelected?(contact) {
                handler(update)
            } else {
                // Default: no errors, use existing summary items from the payment request
                handler(PKPaymentRequestShippingContactUpdate())
            }
        }
    }

    nonisolated func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                                    didSelectShippingMethod shippingMethod: PKShippingMethod,
                                                    handler: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        Task { @MainActor in
            if let update = self.onShippingMethodSelected?(shippingMethod) {
                handler(update)
            } else {
                // Default: no errors, use existing summary items from the payment request
                handler(PKPaymentRequestShippingMethodUpdate(
                    paymentSummaryItems: config.pkPaymentRequest.paymentSummaryItems)
                )
            }
        }
    }
}
