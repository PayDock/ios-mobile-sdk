//
//  PayPalVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 25.10.2023..
//

import SwiftUI

class PayPalVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    private let payPalToken: String
    var payPalUrl: URL?
    @Published var showWebView = false

    // MARK: - Handlers

    private var completion: (Result<ChargeResponse, PayPalError>) -> Void

    // MARK: - Initialisation

    init(payPalToken: String,
         walletService: WalletService = WalletServiceImpl(),
         completion: @escaping (Result<ChargeResponse, PayPalError>) -> Void) {
        self.payPalToken = payPalToken
        self.walletService = walletService
        self.completion = completion
    }

    func getPayPalURL() {
        Task {
            do {
                let payPalUrlString = try await walletService.getCallback(token: self.payPalToken, shipping: false)
                DispatchQueue.main.async {
                    self.payPalUrl = URL(string: payPalUrlString)
                    self.showWebView = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.showWebView = false
                    self.completion(.failure(.webViewFailed))
                }
            }
        }
    }

    func capturePayPalPayment(paymentMethodId: String, payerId: String) {
        Task {
            do {
                let charge = try await walletService.captureCharge(token: payPalToken, paymentMethodId: paymentMethodId, payerId: payerId, refToken: nil)
                DispatchQueue.main.async {
                    self.completion(.success(charge))

                    self.showWebView = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.completion(.failure(.requestFailed))
                    self.showWebView = false
                }
            }
        }
    }

    func handleWebViewFailure(_ error: PayPalError) {
        completion(.failure(error))
    }

}
