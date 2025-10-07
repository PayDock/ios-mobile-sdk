//
//  AfterpayVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.02.2024..
//

import SwiftUI
import Afterpay
import NetworkingLib

@MainActor
class AfterpayVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    let configuration: AfterpaySdkConfig
    private let tokenRequest: (_ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) -> Void
    var viewState: ViewState
    @Published var showWebView = false
    @Published var isLoading = false
    private weak var loadingDelegate: WidgetLoadingDelegate?
    private var token = ""
    private(set) var afterPayOrderId = ""

    // MARK: - Handlers

    let completion: (Result<ChargeResponse, AfterpayError>) -> Void
    private let selectAddress: ((_ address: ShippingAddress, _ provideShippingOptions: ([ShippingOption]) -> Void) -> Void)?
    private let selectShippingOption: ((
        _ shippingOption: ShippingOption,
        _ provideShippingOptionUpdateResult: (ShippingOptionUpdate?) -> Void
    ) -> Void)?
    // MARK: - Initialisation

    init(
        viewState: ViewState,
        configuration: AfterpaySdkConfig,
        tokenRequest: @escaping (
            _ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void
        ) -> Void,
        selectAddress: ((
            _ address: ShippingAddress,
            _ provideShippingOptions: ([ShippingOption]) -> Void
        ) -> Void)?,
        selectShippingOption: ((
            _ shippingOption: ShippingOption,
            _ provideShippingOptionUpdateResult: (ShippingOptionUpdate?) -> Void
        ) -> Void)?,
        walletService: WalletService = WalletServiceImpl(),
        loadingDelegate: WidgetLoadingDelegate?,
        completion: @escaping (Result<ChargeResponse, AfterpayError>) -> Void
    ) {
        self.viewState = viewState
        self.configuration = configuration
        self.tokenRequest = tokenRequest
        self.selectAddress = selectAddress
        self.selectShippingOption = selectShippingOption
        self.walletService = walletService
        self.completion = completion
        self.loadingDelegate = loadingDelegate
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
        guard let vc = UIApplication.shared.topMostViewController() else {
            return
        }

        Afterpay.presentCheckoutV2Modally(
            over: vc,
            animated: true,
            options: .init(
                pickup: configuration.options.pickup,
                buyNow: configuration.options.buyNow,
                shippingOptionRequired: configuration.options.shippingOptionRequired,
                enableSingleShippingOptionUpdate: configuration.options.enableSingleShippingOptionUpdate),
            didCommenceCheckout: { [weak self] completion in
                guard let self = self else { return }
                completion(.success(self.afterPayOrderId))
            },

            shippingAddressDidChange: { [weak self] address, completion in
                guard let selectAddress = self?.selectAddress else { return }
                selectAddress(address, { shippingOption in
                    let result: ShippingOptionsResult = .success(shippingOption)
                    completion(result)
                })

            }, shippingOptionDidChange: { [weak self] shippingOption, completion in
                guard let selectShippingOption = self?.selectShippingOption else { return }
                selectShippingOption(shippingOption, { shippingOptionUpdate in
                    guard let shippingOptionUpdate = shippingOptionUpdate else { return }
                    let result: ShippingOptionUpdateResult = .success(shippingOptionUpdate)
                    completion(result)
                })

            }, completion: { [weak self] result in
                switch result {
                case .success:
                    self?.captureWalletCharge()
                case .cancelled:
                    self?.declineWalletTransaction()
                }
            })
    }

    func getAfterpayURL(token: String) {
        Task {
            do {
                isLoading = true
                let afterPayOrderId = try await walletService.getAfterpayCallback(token: token)
                self.isLoading = false
                self.afterPayOrderId = afterPayOrderId
                self.presentAfterpay()
                self.showWebView = true

            } catch let RequestError.requestError(errorResponse: errorResponse) {
                self.isLoading = false
                self.showWebView = false
                self.completion(.failure(.errorFetchingAfterpayUrl(error: errorResponse)))

            } catch {
                self.isLoading = false
                self.showWebView = false
                self.completion(.failure(.unknownError(error as? RequestError)))
            }
        }
    }

    private func captureWalletCharge() {
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
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                isLoading = false
                completion(.failure(.errorCapturingCharge(error: errorResponse)))
            } catch {
                isLoading = false
                completion(.failure(.unknownError(error as? RequestError)))
            }
        }
    }

    func handleButtonTap() {
        updateLoadingState(isLoading: true)
        tokenRequest { [weak self] result in
            switch result {
            case .success(let response):
                self?.token = response.token
                self?.getAfterpayURL(token: response.token)

            case .failure(let failure):
                self?.updateLoadingState(isLoading: false)
                self?.showWebView = false
                self?.completion(.failure(.initialisingWalletToken(reason: failure.customMessage)))
            }
        }
    }

    func declineWalletTransaction() {
        isLoading = true
        Task {
            do {
                guard let chargeId = decodeChargeId(jwtToken: token) else { return }
                _ = try await walletService.declineWalletTransaction(token: self.token, chargeId: chargeId)
                isLoading = false
                completion(.failure(.transactionCanceled))
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                isLoading = false
                completion(.failure(.errorCancelingTransaction(error: errorResponse)))
            } catch {
                isLoading = false
                self.completion(.failure(.unknownError(error as? RequestError)))
            }
        }
    }

    // MARK: - State Management

    func updateLoadingState(isLoading: Bool) {
        if loadingDelegate != nil {
            if isLoading {
                loadingDelegate?.loadingDidStart()
            } else {
                loadingDelegate?.loadingDidFinish()
            }
        } else {
            self.isLoading = isLoading
        }
        viewState.isDisabled = isLoading
    }
}

// MARK: - JWT Handling

extension AfterpayVM {
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
            base64 += padding
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
