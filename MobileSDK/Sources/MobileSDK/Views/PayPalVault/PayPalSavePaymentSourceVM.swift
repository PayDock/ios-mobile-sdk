//
//  PayPalSavePaymentSourceVM.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 16.10.2024..
//

import SwiftUI
import NetworkingLib

class PayPalSavePaymentSourceVM: ObservableObject {

    // MARK: - Dependencies

    private let payPalVaultService: PayPalVaultService
    private let config: PayPalVaultConfig

    // MARK: - Handlers

    private var completion: (Result<PayPalVaultResult, PayPalVaultError>) -> Void

    // MARK: - Initialisation

    init(config: PayPalVaultConfig,
         payPalVaultService: PayPalVaultService = PayPalVaultMockServiceImpl(),
         completion: @escaping (Result<PayPalVaultResult, PayPalVaultError>) -> Void) {
        self.config = config
        self.payPalVaultService = payPalVaultService
        self.completion = completion
    }
}
