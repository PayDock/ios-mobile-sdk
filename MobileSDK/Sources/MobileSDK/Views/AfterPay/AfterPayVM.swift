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
    private var onAddressChange: ShippingAddressDidChangeClosure?
    private var onShippingChange: ShippingOptionDidChangeClosure?


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
            minimumAmount: "1.00", maximumAmount: "100.00", currencyCode: "AUD", locale: Locale(identifier: "en_AU"), environment: .sandbox)
        Afterpay.setConfiguration(config)
    }

    func presentAfterpay(_ sender: some View) {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        guard let vc = vc else { return }
        Afterpay.presentCheckoutV2Modally(over: vc, animated: true, options: .init()) { completion in
            completion(.success(self.afterPayOrderId))
        } shippingAddressDidChange: { address, completion in
            completion(.success(onAddressChange(address)))

            completion(onAddressChange)
        } shippingOptionDidChange: { shippingOption, complete in
        } completion: { [weak self] result in
            switch result {
            case .success(let token):
                self?.captureWaletCharge()
            case .cancelled(let reason):
                completion(.failure(.webViewFailed))
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
                    paymentMethodId: nil,
                    payerId: nil,
                    refToken: self.afterPayOrderId)
                isLoading = false
                completion(.success("Success"))

            } catch {
                print("error")
                isLoading = false
                completion(.failure(.webViewFailed))

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
