//
//  PayPalVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.10.2023..
//

import SwiftUI
import NetworkingLib

@MainActor
class PayPalVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    private let payPalToken: (_ payPalToken: @escaping (String) -> Void) -> Void
    
    @Published var showWebView = false
    @Published var isLoading = false
    @Published var showLoaders = true
    @Published var sheetAction: SheetAction = SheetAction.nothing
    var options: WidgetOptions
    var payPalUrl: URL?
    private var token = ""

    // MARK: - Handlers

    private var completion: (Result<ChargeResponse, PayPalError>) -> Void
    private weak var loadingDelegate: WidgetLoadingDelegate?

    // MARK: - Initialisation

    init(options: WidgetOptions,
         payPalToken: @escaping (_ payPalToken: @escaping (String) -> Void) -> Void,
         walletService: WalletService = WalletServiceImpl(),
         loadingDelegate: WidgetLoadingDelegate?,
         completion: @escaping (Result<ChargeResponse, PayPalError>) -> Void) {
        self.options = options
        self.payPalToken = payPalToken
        self.walletService = walletService
        self.loadingDelegate = loadingDelegate
        self.completion = completion
        self.sheetAction = SheetAction.nothing
        
        if (loadingDelegate != nil) {
            showLoaders = false
        }
    }

    func getPayPalURL(token: String) {
        Task {
            do {
                await MainActor.run {
                    updateLoadingState(isLoading: true)
                }
                let payPalUrlString = try await walletService.getCallback(token: token, shipping: false)
                await MainActor.run {
                    updateLoadingState(isLoading: false)
                    self.payPalUrl = URL(string: payPalUrlString)
                    self.showWebView = true
                }
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                await MainActor.run {
                    updateLoadingState(isLoading: false)
                    self.sheetAction = .completion
                    self.showWebView = false
                    self.completion(.failure(.errorFetchingPayPalUrl(error: errorResponse)))
                }
            } catch {
                await MainActor.run {
                    updateLoadingState(isLoading: false)
                    self.sheetAction = .completion
                    self.showWebView = false
                    self.completion(.failure(.unknownError))
                }
            }
        }
    }

    func capturePayPalPayment(paymentMethodId: String, payerId: String) {
        guard !token.isEmpty else {
            completion(.failure(.unknownError))
            return
        }

        Task {
            do {
                let charge = try await walletService.captureCharge(token: token, paymentMethodId: paymentMethodId, payerId: payerId, refToken: nil)
                await MainActor.run {
                    self.completion(.success(charge))
                    self.sheetAction = .completion
                    self.showWebView = false
                }
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                await MainActor.run {
                    self.completion(.failure(.errorCapturingCharge(error: errorResponse)))
                    self.sheetAction = .completion
                    self.showWebView = false
                }
            } catch {
                await MainActor.run {
                    self.completion(.failure(.unknownError))
                    self.sheetAction = .completion
                    self.showWebView = false
                }
            }
        }
    }

    func handleButtonTap() {
        updateLoadingState(isLoading: true)
        payPalToken { token in
            self.token = token
            self.getPayPalURL(token: token)
        }
    }

    func handleWebViewFailure(_ error: PayPalError) {
        sheetAction = .completion
        showWebView = false
        completion(.failure(error))
    }
    
    func handleSheetCancellation() {
        completion(.failure(.transactionCanceled))
    }

    func updateLoadingState(isLoading: Bool) {
        if (loadingDelegate != nil) {
            if (isLoading) {
                loadingDelegate?.loadingDidStart()
            } else {
                loadingDelegate?.loadingDidFinish()
            }
        }
        
        self.isLoading = isLoading
        options.isDisabled = isLoading
    }
}
