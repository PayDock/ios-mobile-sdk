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

    // MARK: - Properties

    var paymentController: PKPaymentAuthorizationController?
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var ottToken: String?
    var error: ApplePayError?

    private var isCompletionCalled = false
    private var pkPaymentCompletion: ((PKPaymentAuthorizationStatus) -> Void)?

    // MARK: - Handlers

    private weak var eventDelegate: WidgetEventDelegate?
    private let completion: (Result<String, ApplePayError>) -> Void

    // MARK: - Initialisation

    init(config: ApplePayWidgetConfig,
         eventDelegate: WidgetEventDelegate?,
         paymentSourcesService: DataPaymentSources.PaymentSourcesService = DataPaymentSources.PaymentSourcesServiceImpl(),
         completion: @escaping (Result<String, ApplePayError>) -> Void) {
        self.config = config
        self.eventDelegate = eventDelegate
        self.paymentSourcesService = paymentSourcesService
        self.completion = completion
    }

    func startPayment() {
        paymentController = PKPaymentAuthorizationController(paymentRequest: config.pkPaymentRequest)
        paymentController?.delegate = self
        paymentController?.present(completion: { [weak self] success in
            if !success {
                Task { @MainActor in
                    self?.error = .unableToPresentPaymentSheet
                }
            }
        })
    }

    private func callCompletion(_ completion: (Result<String, ApplePayError>)) {
        guard !isCompletionCalled else { return }
        self.completion(completion)
        isCompletionCalled = true
    }

    // MARK: - OTT Token Creation

    private func createOTTToken(payment: PKPayment) async {
        // Build shipping from shippingContact
        let shipping = buildShipping(from: payment.shippingContact)

        // Build billing from billingContact
        let billing = buildBilling(from: payment.billingContact)

        // Get card scheme from payment method network
        let cardScheme = payment.token.paymentMethod.network?.rawValue ?? ""
        let cardInfo = ApplePayOTTCardInfo(cardScheme: cardScheme)

        // The ref_token is the JSON stringified payment data
        let refToken = String(data: payment.token.paymentData, encoding: .utf8) ?? ""

        // Create the payload
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
            self.error = .payloadEncodingFailed
            self.paymentStatus = .failure
            self.pkPaymentCompletion?(.failure)
            return
        }

        let base64Payload = Data(payloadString.utf8).base64EncodedString()

        // Create the request
        let request = CreateApplePayTokenReq(
            serviceId: config.serviceId,
            payload: base64Payload
        )

        do {
            let token = try await paymentSourcesService.createApplePayToken(
                tokeniseApplePayReq: request,
                widgetAccessToken: config.accessToken
            )
            self.ottToken = token
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
            self.error = .unknownError(nil)
            self.paymentStatus = .failure
            self.pkPaymentCompletion?(.failure)
        }
    }

    private func buildShipping(from contact: PKContact?) -> ApplePayOTTShipping? {
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

    private func buildBilling(from contact: PKContact?) -> ApplePayOTTBilling? {
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
                if self.paymentStatus == .success, let ottToken = self.ottToken {
                    self.callCompletion(.success(ottToken))
                } else {
                    self.callCompletion(.failure(self.error ?? .userCanceledPayment))
                }
            }
        }
    }
}
