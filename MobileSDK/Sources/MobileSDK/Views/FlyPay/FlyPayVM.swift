//
//  FlyPayVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 11.01.2024..
//

import SwiftUI
import NetworkingLib

@MainActor
class FlyPayVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    private let flyPayToken: (_ flyPayToken: @escaping (String) -> Void) -> Void
    var flyPayUrl: URL?
    let clientId: String?
    @Published var showWebView = false
    @Published var isLoading = false
    @Published var sheetAction: SheetAction = SheetAction.nothing
    private var token = ""
    private(set) var flyPayOrderId = ""

    // MARK: - Handlers

    private var completion: (Result<Void, FlyPayError>) -> Void

    // MARK: - Initialisation

    init(clientId: String, flyPayToken: @escaping (_ flyPayToken: @escaping (String) -> Void) -> Void,
         walletService: WalletService = WalletServiceImpl(),
         completion: @escaping (Result<Void, FlyPayError>) -> Void) {
        self.clientId = clientId
        self.flyPayToken = flyPayToken
        self.walletService = walletService
        self.completion = completion
        self.sheetAction = SheetAction.nothing
    }

    func getFlyPayURL(token: String) {
        Task {
            do {
                isLoading = true
                let flyPayOrderId = try await walletService.getFlyPayCallback(token: token)
                await MainActor.run {
                    self.isLoading = false
                    self.flyPayOrderId = flyPayOrderId
                    self.sheetAction = .completion
                    self.showWebView = true
                }
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                await MainActor.run {
                    self.isLoading = false
                    self.sheetAction = .completion
                    self.showWebView = false
                    self.completion(.failure(.errorFetchingFlyPayOrder(error: errorResponse)))
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

    func handleButtonTap() {
        isLoading = true
        flyPayToken { token in
            self.token = token
            self.getFlyPayURL(token: token)
        }
    }

    func handleSuccess() {
        isLoading = false
        sheetAction = .completion
        showWebView = false
        completion(.success(()))
    }

    func handleFailure(error: FlyPayError) {
        isLoading = false
        sheetAction = .completion
        showWebView = false
        completion(.failure(error))
    }
    
    func handleSheetCancellation() {
        completion(.failure(.transactionCanceled))
    }

}
