//
//  AfterPayVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.02.2024..
//

import SwiftUI
import Afterpay

@MainActor
class AfterPayVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    private let afterPayToken: (_ afterPayToken: @escaping (String) -> Void) -> Void
    @Published var showWebView = false
    @Published var isLoading = false
    private var token = ""
    private(set) var afterPayOrderId = ""

    // MARK: - Handlers

    private var completion: (Result<String, AfterPayError>) -> Void

    // MARK: - Initialisation

    init(afterPayToken: @escaping (_ afterPayToken: @escaping (String) -> Void) -> Void,
         walletService: WalletService = WalletServiceImpl(),
         completion: @escaping (Result<String, AfterPayError>) -> Void) {
        self.afterPayToken = afterPayToken
        self.walletService = walletService
        self.completion = completion
        self.setupConfig()
    }

    private func setupConfig() {
        let config = try? Configuration(
            minimumAmount: "1.00", maximumAmount: "2000.00", currencyCode: "AUD", locale: Locale(identifier: "en_AU"), environment: .sandbox)
        Afterpay.setConfiguration(config)
    }

    func presentAfterpay(_ sender: some View) {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        guard let vc = vc else { return }
        Afterpay.presentCheckoutV2Modally(over: vc, animated: true, options: .init()) { completion in
            completion(.success(self.afterPayOrderId))
            print("did Comence checkout")
        } shippingAddressDidChange: { address, completion in
            print("address change")
        } shippingOptionDidChange: { shippingOption, complete in
            print("shipping change")
        } completion: { [weak self] result in
            switch result {
            case .success(let token):
                print("Got the token: \(token)")
                self?.captureWaletCharge()
            case .cancelled(let reason):
                print("Reason for failure: \(reason)")
            }
        }
    }

    func getAfterPayURL(token: String) {
        Task {
            do {
                isLoading = true
                let afterPayOrderId = try await walletService.getAfterPayCallback(token: token)
                await MainActor.run {
                    self.isLoading = false
                    self.afterPayOrderId = afterPayOrderId
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

    private func captureWaletCharge() {
        isLoading = true
        Task {
            do {
                let chargeResponse = try await self.walletService.captureCharge(
                    token: self.token,
                    paymentMethodId: self.afterPayOrderId,
                    payerId: nil,
                    refToken: nil)


            } catch {
                print("error")
            }
        }
    }

    func handleButtonTap() {
        isLoading = true
        afterPayToken { token in
            self.token = token
            self.getAfterPayURL(token: token)
        }
    }

    func handleSuccess() {
        isLoading = false
        showWebView = false
        completion(.success(("TADAA")))
    }

    func handleFailure(error: AfterPayError) {
        isLoading = false
        showWebView = false
        completion(.failure(error))
    }

}
