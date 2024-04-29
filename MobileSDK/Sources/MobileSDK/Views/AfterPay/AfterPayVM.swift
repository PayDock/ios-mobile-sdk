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

    let configuration: AfterpaySdkConfig
    private let afterPayToken: (_ afterPayToken: @escaping (String) -> Void) -> Void
    @Published var showWebView = false
    @Published var isLoading = false
    private var token = ""
    private(set) var afterPayOrderId = ""

    // MARK: - Handlers

    private var completion: (Result<ChargeResponse, AfterPayError>) -> Void
    private var onAddressChange: ShippingAddressDidChangeClosure?
    private var onShippingChange: ShippingOptionDidChangeClosure?


    // MARK: - Initialisation

    init(configuration: AfterpaySdkConfig,
         afterPayToken: @escaping (_ afterPayToken: @escaping (String) -> Void) -> Void,
         walletService: WalletService = WalletServiceImpl(),
         completion: @escaping (Result<ChargeResponse, AfterPayError>) -> Void) {
        self.configuration = configuration
        self.afterPayToken = afterPayToken
        self.walletService = walletService
        self.completion = completion
        self.setupConfig()
    }

    private func setupConfig() {
        let afterpayConfig =  try? Configuration(
            minimumAmount: configuration.config.minimumAmount,
            maximumAmount: configuration.config.maximumAmount,
            currencyCode: configuration.config.currency,
            locale: Locale(identifier: configuration.config.language),
            environment: configuration.environment)
        Afterpay.setConfiguration(afterpayConfig)
    }

    func presentAfterpay() {
        let vc = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.last?.rootViewController
        guard let vc = vc else { return }
        Afterpay.presentCheckoutV2Modally(over: vc, animated: true, options: .init()) { completion in
            completion(.success(self.afterPayOrderId))
        } completion: { [weak self] result in
            switch result {
            case .success:
                self?.captureWaletCharge()
            case .cancelled:
                self?.declineWalletTransaction()
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
                    self.presentAfterpay()
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
                completion(.success(chargeResponse))

            } catch {
                isLoading = false
                completion(.failure(.requestFailed))
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

    func declineWalletTransaction() {
        isLoading = true
        Task {
            do {
                guard let chargeId = decodeChargeId(jwtToken: token) else { return }
                _ = try await walletService.declineWalletTransaction(token: self.token, chargeId: chargeId)
                isLoading = false
                completion(.failure(.webViewFailed))
            } catch {
                print("error")
                isLoading = false
                completion(.failure(.webViewFailed))
            }
        }
    }
}

// MARK: - JWT Handling

extension AfterPayVM {
    private func decodeChargeId(jwtToken jwt: String) -> String? {
        let segments = jwt.components(separatedBy: ".")
        let parts = decodeJWTPart(segments[1]) ?? [:]
        guard let meta = parts["meta"] as? String else {
            print("Error decoding meta token!")
            return nil
        }
        let innerMeta = decodeJWTPart(meta)?["meta"] as? [String: Any]
        let charge = innerMeta?["charge"] as? [String: Any]
        let chargeId = charge?["id"] as? String
        return chargeId
    }

    private func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }

    private func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
            return nil
        }
        return payload
    }
}
