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
    private let createPaymentRequest: (_ createPaymentRequestResult: @escaping (Result<ApplePayRequestResult, ApplePayRequestError>) -> Void) -> Void

    // MARK: - Initialisation

    init(createPaymentRequest: @escaping (_ createPaymentRequestResult: @escaping (Result<ApplePayRequestResult, ApplePayRequestError>) -> Void) -> Void,
         walletService: WalletService = WalletServiceImpl(),
         completion: @escaping (Result<ChargeResponse, ApplePayError>) -> Void) {
        self.createPaymentRequest = createPaymentRequest
        self.walletService = walletService
        self.completion = completion
    }

    func handleButtonTap() {
        error = nil
        createPaymentRequest { [weak self] result in
            switch result {
            case .success(let response):
                self?.applePayRequest = ApplePayRequest(token: response.token, request: response.request)
                self?.startPayment()
            
            case .failure(let failure):
                self?.completion(.failure(.creatingPaymentRequest(reason: failure.customMessage)))
            }
        }
    }

    private func startPayment() {
        guard let applePayRequest = applePayRequest else {
            error = .invalidApplePayRequest
            completion(.failure(.invalidApplePayRequest))
            return
        }

        let paymentRequest = applePayRequest.request
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present(completion: { [weak self] success in
            if !success {
                self?.error = .unableToPresentPaymentSheet
            }
        })
    }
    
    private func captureCharge(payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        guard let applePayRequest = applePayRequest else {
            error = .invalidApplePayRequest
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
}

// MARK: - PKPaymentAuthorizationControllerDelegate

extension ApplePayVM: PKPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                        didAuthorizePayment payment: PKPayment,
                                        completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        captureCharge(payment: payment, completion: completion )
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            if self.paymentStatus == .success, let chargeData = self.chargeData {
                self.completion(.success(chargeData))
            } else {
                self.completion(.failure(self.error ?? .userCanceledPayment))
            }
        }
    }
}
