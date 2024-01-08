//
//  PayPalVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 25.10.2023..
//

import SwiftUI

@MainActor
class PayPalVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    private let payPalToken: (_ payPalToken: @escaping (String) -> Void) -> Void
    var payPalUrl: URL?
    @Published var showWebView = false
    @Published var isLoading = false
    private var token = ""

    // MARK: - Handlers

    private var completion: (Result<ChargeResponse, PayPalError>) -> Void

    // MARK: - Initialisation

    init(payPalToken: @escaping (_ payPalToken: @escaping (String) -> Void) -> Void,
         walletService: WalletService = WalletServiceImpl(),
         completion: @escaping (Result<ChargeResponse, PayPalError>) -> Void) {
        self.payPalToken = payPalToken
        self.walletService = walletService
        self.completion = completion
    }

    func getPayPalURL(token: String) {
        Task {
            do {
                isLoading = true
                let payPalUrlString = try await walletService.getCallback(token: token, shipping: false)
                await MainActor.run {
                    self.isLoading = false
                    self.payPalUrl = URL(string: payPalUrlString)
                    self.showWebView = true
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.showWebView = false
                    self.completion(.failure(.webViewFailed))
                }
            }
        }
    }

    func capturePayPalPayment(paymentMethodId: String, payerId: String) {
        guard !token.isEmpty else {
            completion(.failure(.requestFailed))
            return
        }

        Task {
            do {
                let charge = try await walletService.captureCharge(token: token, paymentMethodId: paymentMethodId, payerId: payerId, refToken: nil)
                await MainActor.run {
                    self.isLoading = false
                    self.completion(.success(charge))
                    self.showWebView = false
                }

            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.completion(.failure(.requestFailed))
                    self.showWebView = false
                }
            }
        }
    }

    func handleButtonTap() {
        isLoading = true
        payPalToken { token in
            self.token = token
            self.getPayPalURL(token: token)
        }
    }

    func handleWebViewFailure(_ error: PayPalError) {
        completion(.failure(error))
    }

}
