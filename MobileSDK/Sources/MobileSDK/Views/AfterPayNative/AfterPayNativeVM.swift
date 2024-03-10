//
//  AfterPayNativeVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 22.02.2024..
//  Copyright © 2024 Paydock Ltd.
//

import SwiftUI
import Afterpay

@MainActor
class AfterPayNativeVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    private let afterPayToken: (_ afterPayToken: @escaping (String) -> Void) -> Void
    var afterPayUrl: URL?
    @Published var showWebView = false
    @Published var isLoading = false
    private var token = ""
    private(set) var afterPayOrderId = ""
    @Published var webUrl: URL? = nil

    // MARK: - Handlers

    private var completion: (Result<Void, AfterPayError>) -> Void

    // MARK: - Initialisation

    init(afterPayToken: @escaping (_ afterPayToken: @escaping (String) -> Void) -> Void,
         walletService: WalletService = WalletServiceImpl(),
         completion: @escaping (Result<Void, AfterPayError>) -> Void) {
        self.afterPayToken = afterPayToken
        self.walletService = walletService
        self.completion = completion
    }

    func getAfterPayURL(token: String) {
        Task {
            do {
                isLoading = true
                let afterPayOrderId = try await walletService.getAfterPayCallback(token: token)
                await MainActor.run {
                    self.isLoading = false
                    self.afterPayOrderId = afterPayOrderId
                    self.webUrl = URL(string:"https://portal.sandbox.afterpay.com/au/checkout/?token=\(afterPayOrderId)")
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
        completion(.success(()))
    }

    func handleFailure(error: AfterPayError) {
        isLoading = false
        showWebView = false
        completion(.failure(error))
    }

    func initializeAfterpaySDK() {
        do {
            let configuration = try Afterpay.Configuration(minimumAmount: "0", maximumAmount: "100", currencyCode: "AUD", locale: .current, environment: .sandbox)
            Afterpay.setConfiguration(configuration)
        } catch {
            print("Error initializing afterpay")
        }
    }

}
