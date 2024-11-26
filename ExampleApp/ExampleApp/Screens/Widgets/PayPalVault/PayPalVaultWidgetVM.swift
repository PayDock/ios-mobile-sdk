//
//  PayPalVaultWidgetVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 24.10.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK

class PayPalVaultWidgetVM: ObservableObject {

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isLoading = false
    
    // MARK: - Config
    
    func getConfig() -> PayPalVaultConfig {
        let accessToken = ProjectEnvironment.shared.getAccessToken()
        let gatewayId = ProjectEnvironment.shared.getPayPalGatewayId() ?? ""
        let config = PayPalVaultConfig(accessToken: accessToken, gatewayId: gatewayId)
        return config
    }
    
    // MARK: - Completion handling

    func handleError(error: PayPalVaultError) {
        alertTitle = "Error"
        alertMessage = "\(error.customMessage)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAlert = true
        }
    }

    func handleSuccess(result: PayPalVaultResult) {
        alertTitle = "Success"
        alertMessage = "Token:\n \(result.token)\n\n Email:\n \(result.email)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAlert = true
        }
    }
}

extension PayPalVaultWidgetVM: WidgetLoadingDelegate {
    func loadingDidStart() {
        isLoading = true
    }
    
    func loadingDidFinish() {
        isLoading = false
    }
}
