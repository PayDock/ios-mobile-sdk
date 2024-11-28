//
//  AccountProfileVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

class AccountProfileVM: ObservableObject {
    
    private let customersService: CustomersService
    
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    init(customersService: CustomersService = CustomersServiceImpl()) {
        self.customersService = customersService
    }
    
    func getVaultConfig() -> PayPalVaultConfig {
        let config = PayPalVaultConfig(
            accessToken: ProjectEnvironment.shared.getAccessToken(),
            gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? "")
        return config
    }
    
    func handleError(error: PayPalVaultError) {
        alertTitle = "Error"
        alertMessage = "\(error.customMessage)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showAlert = true
        }
    }

    func handleSuccess(result: PayPalVaultResult) {
//        alertTitle = "Success"
//        alertMessage = "Token:\n \(result.token)\n\n Email:\n \(result.email)"
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.showAlert = true
//        }
        createCustomer(payPalVaultResult: result)
    }
    
    private func createCustomer(payPalVaultResult: PayPalVaultResult) {
        Task {
            let request = CreateCustomerTokenReq(token: payPalVaultResult.token)
            do {
                let response = try await customersService.createCustomer(request: request)
                print("a")
            } catch {
                print("some error")
            }
        }
    }
}
