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

    private let payPalVaultService: PayPalVaultService
    private let config: PayPalVaultConfig
    
    // MARK: - Properties
    
    @Published var actionText: String = ""
    @Published var isLoading = false

    // MARK: - Handlers

    private var completion: (Result<PayPalVaultResult, PayPalVaultError>) -> Void

    // MARK: - Initialisation

    init(config: PayPalVaultConfig,
         payPalVaultService: PayPalVaultService = PayPalVaultServiceImpl(),
         completion: @escaping (Result<PayPalVaultResult, PayPalVaultError>) -> Void) {
        self.config = config
        self.payPalVaultService = payPalVaultService
        self.completion = completion
        
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
                  let authToken = await getAuthToken(),
                  let setupTokenData = await getSetupTokenData(authToken: authToken) else {
                isLoading = false
                return
            }
            
            // TODO: - Use the URL from the response once it's live on BE
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
        isLoading = true
        do {
            return try await payPalVaultService.getClientId(gatewayId: config.gatewayId, accessToken: config.accessToken)
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.getPayPalClientId(error: errorResponse)))
            isLoading = false
        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
            isLoading = false
        }
        return nil
    }
    
    @MainActor
    func getAuthToken() async -> String? {
        isLoading = true
        do {
            let request = PayPalVaultAuthReq(gatewayId: config.gatewayId)
            return try await payPalVaultService.createToken(request: request, accessToken: config.accessToken)
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.createSessionAuthToken(error: errorResponse)))
            isLoading = false
        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
            isLoading = false
        }
        return nil
    }
    
    @MainActor
    func getSetupTokenData(authToken: String) async -> PayPalVaultSetupTokenRes.SetupTokenData? {
        isLoading = true
        do {
            let request = PayPalVaultSetupTokenReq(gatewayId: config.gatewayId, token: authToken)
            return try await payPalVaultService.createSetupTokenData(req: request, accessToken: config.accessToken)
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.createSetupToken(error: errorResponse)))
            isLoading = false
        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
            isLoading = false
        }
        return nil
    }
    
    @MainActor
    func createPaymentToken(setupToken: String) async {
        isLoading = true
        do {
            let request = PayPalVaultPaymentTokenReq(gatewayId: config.gatewayId)
            let tokenData = try await payPalVaultService.createPaymentToken(request: request, setupToken: setupToken, accessToken: config.accessToken)
            isLoading = false
            completion(.success(PayPalVaultResult(token: tokenData.token, email: tokenData.email)))
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.createPaymentToken(error: errorResponse)))
            isLoading = false
        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
            isLoading = false
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
        isLoading = false
    }
    
    func paypalDidCancel(_ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient) {
        completion(.failure(.userCancelled))
        isLoading = false
    }
    
}
