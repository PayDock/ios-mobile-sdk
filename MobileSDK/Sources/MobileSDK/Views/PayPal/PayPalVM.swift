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

    private var onCompletion: Binding<ChargeResponse?>
    private var onFailure: Binding<PayPalError?>

    // MARK: - Initialisation

    init(payPalToken: String,
         walletService: WalletService = WalletServiceImpl(),
         onCompletion: Binding<ChargeResponse?>,
         onFailure: Binding<PayPalError?>) {
        self.payPalToken = payPalToken
        self.walletService = walletService
        self.onCompletion = onCompletion
        self.onFailure = onFailure
    }

    func getPayPalURL() {
        Task {
            do {
                let payPalUrlString = try await walletService.getCallback(token: self.payPalToken)
                DispatchQueue.main.async {
                    self.payPalUrl = URL(string: payPalUrlString)
                    self.showWebView = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.showWebView = false
                    self.onFailure.wrappedValue = .webViewFailed
                }
            }
        }
    }

    func capturePayPalPayment(paymentMethodId: String, payerId: String) {
        Task {
            do {
                let charge = try await walletService.captureCharge(token: payPalToken, paymentMethodId: paymentMethodId, payerId: payerId, refToken: nil)
                DispatchQueue.main.async {
                    self.onCompletion.wrappedValue = charge
                    self.showWebView = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.onFailure.wrappedValue = .requestFailed
                    self.showWebView = false
                }
            }
        }
    }

    func handleWebViewFailure(_ error: PayPalError) {
        onFailure.wrappedValue = error
    }

}
