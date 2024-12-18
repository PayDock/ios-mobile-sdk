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
            gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? "",
            icon: .customIcon(image: Image("payPalSmall")))
        return config
    }
    
    @MainActor func handleError(error: PayPalVaultError) {
        showAlert(title: "Error", message: "\(error.customMessage)")
    }
    
    func createCustomer(payPalVaultResult: PayPalVaultResult) {
        Task {
            let request = CreateCustomerTokenReq(token: payPalVaultResult.token)
            do {
                let response = try await customersService.createCustomer(request: request)
                await showAlert(
                    title: "Customer Created",
                    message: "\(response.resource.data.firstName) \(response.resource.data.lastName)\n\(response.resource.data.email)")
            } catch {
                await showAlert(title: "Error", message: "Customer creation failed!")
            }
        }
    }
    
    @MainActor
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
