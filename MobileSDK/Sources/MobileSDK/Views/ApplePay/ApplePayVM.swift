//
//  ApplePayVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 04.10.2023..
//

import SwiftUI
import PassKit

class ApplePayVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    @Published var isLoading = false
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
        isLoading = true
        applePayRequestHandler { applePayRequest in
            self.isLoading = false
            self.applePayRequest = applePayRequest
            self.startPayment()
        }
    }

    private func startPayment() {
        guard let applePayRequest = applePayRequest else {
            completion(.failure(.paymentFailed))
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
            self.completion(.failure(.paymentFailed))
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
                isLoading = false
                completion(paymentStatus)

            } catch {
                paymentStatus = .failure
                self.error = .paymentFailed
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
                    self.completion(.failure(self.error ?? .paymentFailed))
                }
            }
        }
    }
}


