//
//  ColesPayVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 11.01.2024..
//

import SwiftUI
import NetworkingLib

@MainActor
class ColesPayVM: ObservableObject {

    // MARK: - Dependencies

    private let walletService: WalletService

    // MARK: - Properties

    private let colesPayToken: (_ colesPayToken: @escaping (String) -> Void) -> Void
    var colesPayUrl: URL?
    let clientId: String?
    @Published var showWebView = false
    @Published var isLoading = false
    @Published var showLoaders = true
    @Published var showCancelConfirmation = false
    var viewState: ViewState
    private var token = ""
    private(set) var colesPayOrderId = ""

    // MARK: - Handlers

    private var completion: (Result<String, ColesPayError>) -> Void
    private weak var loadingDelegate: WidgetLoadingDelegate?

    // MARK: - Initialisation

    init(clientId: String, colesPayToken: @escaping (_ colesPayToken: @escaping (String) -> Void) -> Void,
         walletService: WalletService = WalletServiceImpl(),
         viewState: ViewState,
         loadingDelegate: WidgetLoadingDelegate?,
         completion: @escaping (Result<String, ColesPayError>) -> Void) {
        self.clientId = clientId
        self.colesPayToken = colesPayToken
        self.walletService = walletService
        self.viewState = viewState
        self.loadingDelegate = loadingDelegate
        self.completion = completion
        
        if (loadingDelegate != nil) {
            showLoaders = false
        }
    }

    func getColesPayURL(token: String) {
        Task {
            do {
                updateLoadingState(isLoading: true)
                let colesPayOrderId = try await walletService.getColesPayCallback(token: token)
                self.isLoading = false
                self.colesPayOrderId = colesPayOrderId
                self.showWebView = true
                
            } catch let RequestError.requestError(errorResponse: errorResponse) {
                self.updateLoadingState(isLoading: false)
                self.showWebView = false
                self.completion(.failure(.errorFetchingColesPayOrder(error: errorResponse)))
                
            } catch {
                updateLoadingState(isLoading: false)
                self.showWebView = false
                self.completion(.failure(.unknownError))
            }
        }
    }

    func handleButtonTap() {
        updateLoadingState(isLoading: true)
        colesPayToken { token in
            self.token = token
            self.getColesPayURL(token: token)
        }
    }

    func handleSuccess() {
        updateLoadingState(isLoading: false)
        showWebView = false
        completion(.success((colesPayOrderId)))
    }

    func handleFailure(error: ColesPayError) {
        updateLoadingState(isLoading: false)
        showWebView = false
        completion(.failure(error))
    }
    
    func handleSheetCancellation() {
        updateLoadingState(isLoading: false)
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
