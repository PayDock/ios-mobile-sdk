//
//  MastercardVM.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 10.03.2024..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation

import SwiftUI

@MainActor
class MastercardVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

//    private let flyPayToken: (_ flyPayToken: @escaping (String) -> Void) -> Void
    var flyPayUrl: URL?
    @Published var showWebView = false
    @Published var isLoading = false
    private var token = ""
    private(set) var flyPayOrderId = ""

    // MARK: - Handlers

//    private var completion: (Result<Void, FlyPayError>) -> Void

    // MARK: - Initialisation

    init(walletService: WalletService = WalletServiceImpl()) {
        self.walletService = walletService
    }

//    func getFlyPayURL(token: String) {
//        Task {
//            do {
//                isLoading = true
//                let flyPayOrderId = try await walletService.getFlyPayCallback(token: token)
//                await MainActor.run {
//                    self.isLoading = false
//                    self.flyPayOrderId = flyPayOrderId
//                    self.showWebView = true
//                }
//            } catch {
//                await MainActor.run {
//                    self.isLoading = false
//                    self.showWebView = false
//                    self.completion(.failure(.webViewFailed))
//                }
//            }
//        }
//    }
//
//    func handleButtonTap() {
//        isLoading = true
//        flyPayToken { token in
//            self.token = token
//            self.getFlyPayURL(token: token)
//        }
//    }
//
//    func handleSuccess() {
//        isLoading = false
//        showWebView = false
//        completion(.success(()))
//    }
//
//    func handleFailure(error: FlyPayError) {
//        isLoading = false
//        showWebView = false
//        completion(.failure(error))
//    }
    func getBaseUrl() -> URL? {
        let urlString = "https://paydock.com"
        return URL(string: urlString)
    }
}
