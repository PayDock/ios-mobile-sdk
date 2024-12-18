//
//  PayPalSavePaymentSourceVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 16.10.2024..
//

import SwiftUI
import NetworkingLib
import CorePayments
import PayPalWebPayments

class PayPalSavePaymentSourceVM: ObservableObject {

    // MARK: - Dependencies

    let config: PayPalVaultConfig
    private let payPalVaultService: PayPalVaultService
    
    // MARK: - Properties
    
    @Published var actionText: String = ""
    @Published var isLoading = false
    @Published var showLoaders = true
    var viewState: ViewState
    private weak var loadingDelegate: WidgetLoadingDelegate?

    // MARK: - Handlers

    private var completion: (Result<PayPalVaultResult, PayPalVaultError>) -> Void

    // MARK: - Initialisation

    init(viewState: ViewState,
         config: PayPalVaultConfig,
         payPalVaultService: PayPalVaultService = PayPalVaultServiceImpl(),
         loadingDelegate: WidgetLoadingDelegate?,
         completion: @escaping (Result<PayPalVaultResult, PayPalVaultError>) -> Void) {
        self.viewState = viewState
        self.config = config
        self.payPalVaultService = payPalVaultService
        self.loadingDelegate = loadingDelegate
        self.completion = completion
        
        if (loadingDelegate != nil) {
            showLoaders = false
        }
        
        setUp()
    }
    
    private func setUp() {
        actionText = config.actionText ?? "Link PayPal account"
    }
    
    // MARK: - PayPal Initialization
    
    @MainActor
    func initializePayPalSDK() {
        Task {
            guard let clientId = await getClientId(),
                  let setupTokenData = await getSetupTokenData() else {
                updateLoadingState(isLoading: false)
                return
            }
            
            let vaultRequest = PayPalVaultRequest(url: setupTokenData.approveLink, setupTokenID: setupTokenData.setupToken)
            let environment = Constants.payPalVaultEnvironment
            let payPalConfig = CoreConfig(clientID: clientId, environment: environment)
            let payPalClient = PayPalWebCheckoutClient(config: payPalConfig)
            
            payPalClient.vaultDelegate = self
            payPalClient.vault(vaultRequest)
        }
    }
    
    @MainActor
    func getClientId() async -> String? {
        updateLoadingState(isLoading: true)
        do {
            return try await payPalVaultService.getClientId(gatewayId: config.gatewayId, accessToken: config.accessToken)
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.getPayPalClientId(error: errorResponse)))
            updateLoadingState(isLoading: false)
        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
            updateLoadingState(isLoading: false)
        }
        return nil
    }
    
    @MainActor
    func getSetupTokenData() async -> PayPalVaultSetupTokenRes.SetupTokenData? {
        updateLoadingState(isLoading: true)
        do {
            let request = PayPalVaultSetupTokenReq(gatewayId: config.gatewayId)
            return try await payPalVaultService.createSetupTokenData(req: request, accessToken: config.accessToken)
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.createSetupToken(error: errorResponse)))
            updateLoadingState(isLoading: false)
        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
            updateLoadingState(isLoading: false)
        }
        return nil
    }
    
    @MainActor
    func createPaymentToken(setupToken: String) async {
        updateLoadingState(isLoading: true)
        do {
            let request = PayPalVaultPaymentTokenReq(gatewayId: config.gatewayId)
            let tokenData = try await payPalVaultService.createPaymentToken(request: request, setupToken: setupToken, accessToken: config.accessToken)
            updateLoadingState(isLoading: false)
            completion(.success(PayPalVaultResult(token: tokenData.token, email: tokenData.email)))
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.createPaymentToken(error: errorResponse)))
            updateLoadingState(isLoading: false)
        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
            updateLoadingState(isLoading: false)
        }
    }
    
    // MARK: - State Management
    
    func updateLoadingState(isLoading: Bool) {
        if (loadingDelegate != nil) {
            if (isLoading) {
                loadingDelegate?.loadingDidStart()
            } else {
                loadingDelegate?.loadingDidFinish()
            }
        }
        
        self.isLoading = isLoading
        self.viewState.isDisabled = isLoading
    }
    
    // MARK: - Helpers
    
    func getButtonIcon() -> Image? {
        switch config.icon {
        case .none: return nil
        case .defaultIcon: return Image("link", bundle: Bundle.module)
        case .customIcon(let image): return image
        }
    }
}

// MARK: - PayPalVaultDelegate

extension PayPalSavePaymentSourceVM: PayPalVaultDelegate {
    
    func paypal(_ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient, didFinishWithVaultResult paypalVaultResult: PayPalWebPayments.PayPalVaultResult) {
        Task {
            await createPaymentToken(setupToken: paypalVaultResult.tokenID)
        }
    }
    
    func paypal(_ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient, didFinishWithVaultError vaultError: CorePayments.CoreSDKError) {
        let errorDescription = vaultError.errorDescription ?? ""
        completion(.failure(.sdkException(description: errorDescription)))
        updateLoadingState(isLoading: false)
    }
    
    func paypalDidCancel(_ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient) {
        completion(.failure(.userCancelled))
        updateLoadingState(isLoading: false)
    }
}
