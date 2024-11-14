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
    
    func initializePayPalSDK() {
        Task {
            guard let clientId = await getClientId(),
                  let authToken = await getAuthToken(),
                  let setupTokenData = await getSetupTokenData(authToken: authToken) else {
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
    
    func getClientId() async -> String? {
        do {
            return try await payPalVaultService.getClientId(gatewayId: config.gatewayId, accessToken: config.accessToken)
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.getPayPalClientId(error: errorResponse)))
        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
        }
        return nil
    }
    
    func getAuthToken() async -> String? {
        do {
            let request = PayPalVaultAuthReq(gatewayId: config.gatewayId)
            return try await payPalVaultService.createToken(request: request, accessToken: config.accessToken)
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.createSessionAuthToken(error: errorResponse)))
        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
        }
        return nil
    }
    
    func getSetupTokenData(authToken: String) async -> PayPalVaultSetupTokenRes.SetupTokenData? {
        do {
            let request = PayPalVaultSetupTokenReq(gatewayId: config.gatewayId, token: authToken)
            return try await payPalVaultService.createSetupTokenData(req: request, accessToken: config.accessToken)
        } catch let RequestError.requestError(errorResponse: errorResponse) {
            completion(.failure(.createSetupToken(error: errorResponse)))
        } catch {
            completion(.failure(.unknownError(error as? RequestError)))
        }
        return nil
    }
}

// MARK: - PayPalVaultDelegate

extension PayPalSavePaymentSourceVM: PayPalVaultDelegate {
    
    func paypal(_ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient, didFinishWithVaultResult paypalVaultResult: PayPalWebPayments.PayPalVaultResult) {
        let result = PayPalVaultResult(token: paypalVaultResult.approvalSessionID)
        completion(.success(result))
    }
    
    func paypal(_ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient, didFinishWithVaultError vaultError: CorePayments.CoreSDKError) {
        let errorDescription = vaultError.errorDescription ?? ""
        completion(.failure(.sdkException(description: errorDescription)))
    }
    
    func paypalDidCancel(_ paypalWebClient: PayPalWebPayments.PayPalWebCheckoutClient) {
        completion(.failure(.userCancelled))
    }
    
}
