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

    private let tokenRequest: (_ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) -> Void

    @Published var showWebView = false
    @Published var isLoading = false
    @Published var showLoaders = true
    @Published var showCancelConfirmation = false
    var viewState: ViewState
    var payPalUrl: URL?
    private var token = ""

    // MARK: - Handlers

    private var completion: (Result<ChargeResponse, PayPalError>) -> Void
    private weak var loadingDelegate: WidgetLoadingDelegate?

    // MARK: - Initialisation

    init(viewState: ViewState,
         tokenRequest: @escaping (_ tokenResult: @escaping (Result<WalletTokenResult, WalletTokenError>) -> Void) -> Void,
         walletService: WalletService = WalletServiceImpl(),
         loadingDelegate: WidgetLoadingDelegate?,
         completion: @escaping (Result<ChargeResponse, PayPalError>) -> Void) {
        self.viewState = viewState
        self.tokenRequest = tokenRequest
        self.walletService = walletService
        self.loadingDelegate = loadingDelegate
        self.completion = completion
        
        if (loadingDelegate != nil) {
            showLoaders = false
        }
    }

    func getPayPalURL(token: String) {
        Task {
            do {
                updateLoadingState(isLoading: true)
                let payPalUrlString = try await walletService.getCallback(token: token, shipping: false)
                updateLoadingState(isLoading: false)
                self.payPalUrl = URL(string: payPalUrlString)
                withAnimation {
                    self.showWebView = true
                }
                
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                updateLoadingState(isLoading: false)
                self.showWebView = false
                self.completion(.failure(.errorFetchingPayPalUrl(error: errorResponse)))
                
            } catch {
                updateLoadingState(isLoading: false)
                self.showWebView = false
                self.completion(.failure(.unknownError))
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
                self.completion(.success(charge))
                self.showWebView = false
                
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                self.completion(.failure(.errorCapturingCharge(error: errorResponse)))
                self.showWebView = false
                
            } catch {
                self.completion(.failure(.unknownError))
                self.showWebView = false
            }
        }
    }

    func handleButtonTap() {
        updateLoadingState(isLoading: true)
        tokenRequest { [weak self] result in
            switch result {
            case .success(let response):
                self?.token = response.token
                self?.getPayPalURL(token: response.token)
            
            case .failure(let failure):
                self?.updateLoadingState(isLoading: false)
                self?.showWebView = false
                self?.completion(.failure(.initialisingWalletToken(reason: failure.customMessage)))
            }
        }
    }

    func handleWebViewFailure(_ error: PayPalError) {
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
        viewState.isDisabled = isLoading
    }
}
