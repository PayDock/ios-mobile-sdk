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
    var payPalUrl: URL?
    @Published var showWebView = false
    @Published var isLoading = false
    @Published var sheetAction: SheetAction = SheetAction.nothing

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
        self.sheetAction = SheetAction.nothing
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
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                await MainActor.run {
                    self.isLoading = false
                    self.sheetAction = .completion
                    self.showWebView = false
                    self.completion(.failure(.errorFetchingPayPalUrl(error: errorResponse)))
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
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
                    self.isLoading = false
                    self.completion(.success(charge))
                    self.sheetAction = .completion
                    self.showWebView = false
                }
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                await MainActor.run {
                    self.isLoading = false
                    self.completion(.failure(.errorCapturingCharge(error: errorResponse)))
                    self.sheetAction = .completion
                    self.showWebView = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.completion(.failure(.unknownError))
                    self.sheetAction = .completion
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
        isLoading = false
        sheetAction = .completion
        showWebView = false
        completion(.failure(error))
    }
    
    func handleSheetCancellation() {
        completion(.failure(.transactionCanceled))
    }

}
