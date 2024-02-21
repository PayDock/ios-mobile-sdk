//
//  AfterPayVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 19.02.2024..
//

import SwiftUI

@MainActor
class AfterPayVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    private let afterPayToken: (_ afterPayToken: @escaping (String) -> Void) -> Void
    var afterPayUrl: URL?
    @Published var showWebView = false
    @Published var isLoading = false
    private var token = ""
    private(set) var afterPayOrderId = ""

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

}
