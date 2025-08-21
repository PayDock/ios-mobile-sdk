//
//  AccountProfileVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

@MainActor
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
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? "",
            icon: .customIcon(image: Image("payPalSmall")))
        return config
    }

    func handleError(error: PayPalVaultError) {
        showAlert(title: "Error", message: "\(error.customMessage)")
    }

    func createCustomer(payPalVaultResult: PayPalVaultResult) {
        Task {
            let request = CreateCustomerTokenReq(token: payPalVaultResult.token)
            do {
                let response = try await customersService.createCustomer(request: request)
                showAlert(
                    title: "Customer Created",
                    message:
                        "\(response.resource.data.firstName) "
                        + "\(response.resource.data.lastName)\n"
                        + "\(response.resource.data.email ?? "")"
                )
            } catch {
                showAlert(title: "Error", message: "Customer creation failed!")
            }
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
