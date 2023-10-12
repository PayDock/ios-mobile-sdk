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
    let applePayRequest: ApplePayRequest

    // MARK: - Properties

    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var chargeData: ChargeResponse?
    var error: ApplePayError?

    // MARK: - Handlers

    private var onCompletion: Binding<ChargeResponse?>
    private var onFailure: Binding<ApplePayError?>

    init(applePayRequest: ApplePayRequest,
         walletService: WalletService = WalletServiceImpl(),
         onCompletion: Binding<ChargeResponse?>,
         onFailure: Binding<ApplePayError?>) {
        self.applePayRequest = applePayRequest
        self.walletService = walletService
        self.onCompletion = onCompletion
        self.onFailure = onFailure
    }

    func startPayment() {
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
        // Check if we need some additonal validation config before firing
        if false {
            paymentStatus = .failure
            completion(paymentStatus)
        } else {
            Task {
                do {
                    let refToken = String(data: payment.token.paymentData, encoding: .utf8)
                    let chargeResponse = try await self.walletService.captureCharge(
                        token: self.applePayRequest.token,
                        paymentMethodId: nil,
                        payerId: nil,
                        refToken: refToken)

                    paymentStatus = .success
                    onCompletion.wrappedValue = chargeResponse
                    completion(paymentStatus)

                } catch {
                    paymentStatus = .failure
                    self.error = .paymentFailed
                    completion(paymentStatus)
                }
            }
        }
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            DispatchQueue.main.async {
                if self.paymentStatus == .success, let chargeData = self.chargeData {
                    self.onCompletion.wrappedValue = chargeData
                } else {
                    self.onFailure.wrappedValue = self.error
                }
            }
        }
    }
}


