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
         payPalVaultService: PayPalVaultService = PayPalVaultMockServiceImpl(),
         completion: @escaping (Result<PayPalVaultResult, PayPalVaultError>) -> Void) {
        self.config = config
        self.payPalVaultService = payPalVaultService
        self.completion = completion
        
        setUp()
    }
    
    private func setUp() {
        actionText = config.actionText ?? "Link PayPal account"
    }
    
    func initializePayPalSDK() {
        // TODO: - Testing data - use postman to obtain
        let clientID = "AY-iOYV1QKAX6ZRomt-gXigd0-pToRMwdoLW4UxFSITOApI2jUa5UgM39MKC0qeip3SCbPozbAusuGO0"
        let setupTokenID = "1B309495S0244553F"
        let vaultReq = PayPalVaultRequest(url: URL(string: "https://www.sandbox.paypal.com/agreements/approve?approval_session_id=\(setupTokenID)")!, setupTokenID: setupTokenID)
        let environment = Constants.payPalVaultEnvironment
        
        let payPalConfig = CoreConfig(clientID: clientID, environment: environment)
        let payPalClient = PayPalWebCheckoutClient(config: payPalConfig)
        
        payPalClient.vaultDelegate = self
        payPalClient.vault(vaultReq)
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
