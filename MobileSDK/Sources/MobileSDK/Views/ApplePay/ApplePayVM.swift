//
//  ApplePayVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 04.10.2023..
//

import SwiftUI
import PassKit
import NetworkingLib

class ApplePayVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    private var applePayRequest: ApplePayRequest?
    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var chargeData: ChargeResponse?
    var error: ApplePayError?

    // MARK: - Handlers

    private let completion: (Result<ChargeResponse, ApplePayError>) -> Void
    private let applePayRequestHandler: (_ applePayRequest: @escaping (ApplePayRequest) -> Void) -> Void

    // MARK: - Initialisation

    init(applePayRequestHandler: @escaping (_ applePayRequest: @escaping (ApplePayRequest) -> Void) -> Void,
         walletService: WalletService = WalletServiceImpl(),
         completion: @escaping (Result<ChargeResponse, ApplePayError>) -> Void) {
        self.applePayRequestHandler = applePayRequestHandler
        self.walletService = walletService
        self.completion = completion
    }

    func handleButtonTap() {
        applePayRequestHandler { applePayRequest in
            self.applePayRequest = applePayRequest
            self.startPayment()
        }
    }

    private func startPayment() {
        guard let applePayRequest = applePayRequest else {
            completion(.failure(.invalidApplePayRequest))
            return
        }

        let paymentRequest = applePayRequest.request
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present()
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate

extension ApplePayVM: PKPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                        didAuthorizePayment payment: PKPayment,
                                        completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        guard let applePayRequest = applePayRequest else {
            self.completion(.failure(.invalidApplePayRequest))
            return
        }

        Task {
            do {
                let refToken = String(data: payment.token.paymentData, encoding: .utf8)
                let chargeResponse = try await self.walletService.captureCharge(
                    token: applePayRequest.token,
                    paymentMethodId: nil,
                    payerId: nil,
                    refToken: refToken)

                paymentStatus = .success
                self.completion(.success(chargeResponse))
                completion(paymentStatus)
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                paymentStatus = .failure
                self.error = .errorCompletingPayment(error: errorResponse)
                completion(paymentStatus)
            } catch {
                paymentStatus = .failure
                self.error = .unknownError
                completion(paymentStatus)
            }
        }
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            DispatchQueue.main.async {
                if self.paymentStatus == .success, let chargeData = self.chargeData {
                    self.completion(.success(chargeData))
                } else {
                    self.completion(.failure(self.error ?? .unknownError))
                }
            }
        }
    }
}
