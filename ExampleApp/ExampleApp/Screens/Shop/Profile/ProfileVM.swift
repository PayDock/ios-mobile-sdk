//
//  AccountProfileVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 27.11.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK
import DataCustomer

@MainActor
class ProfileVM: ObservableObject {

    private let customersService: DataCustomer.CustomersService
    private let profileManager = UserProfileManager.shared
    private let configManager = ConfigManager.shared

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isLoading = false

    // Computed properties that delegate to UserProfileManager
    var isCustomerLinked: Bool {
        profileManager.isCustomerLinked
    }

    var linkedCustomerInfo: CustomerInfo? {
        profileManager.linkedCustomerInfo
    }

    init(customersService: DataCustomer.CustomersService = DataCustomer.CustomersServiceImpl()) {
        self.customersService = customersService
    }

    private var apiAccessToken: String {
        return configManager.getGlobalConfig().apiAccessToken
    }

    func getVaultConfig() -> PayPalVaultConfig {
        let config = PayPalVaultConfig(
            accessToken: ProjectEnvironment.shared.getWidgetAccessToken(),
            gatewayId: ProjectEnvironment.shared.getPayPalGatewayId() ?? "")
        return config
    }

    func getVaultAppearance() -> PayPalVaultAppearance {
        var appearance = PayPalVaultAppearance()
        appearance.actionButton.icon = Image("payPalSmall")
        return appearance
    }

    func handleError(error: PayPalVaultError) {
        showAlert(title: "Error", message: "\(error.customMessage)")
    }

    func createCustomer(payPalVaultResult: PayPalVaultResult) {
        Task {
            let request = DataCustomer.CreateCustomerTokenReq(token: payPalVaultResult.token)
            do {
                let response = try await customersService.createCustomer(request: request, apiAccessToken: apiAccessToken)

                // Store the customer information using UserProfileManager
                let customerInfo = CustomerInfo(
                    firstName: response.resource.firstName ?? "",
                    lastName: response.resource.lastName ?? "",
                    phone: response.resource.phone ?? "",
                    email: payPalVaultResult.email
                )

                profileManager.linkCustomer(customerInfo: customerInfo)

                showAlert(
                    title: "Customer Linked Successfully",
                    message: """
                    Account linked with:
                    \(response.resource.firstName) \(response.resource.lastName)
                    \(response.resource.phone)
                    \(payPalVaultResult.email)
                    """
                )
            } catch {
                showAlert(title: "Error", message: "Customer linking failed!")
            }
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }

    func unlinkCustomer() {
        profileManager.unlinkCustomer()
        showAlert(title: "Account Unlinked", message: "PayPal account has been unlinked successfully.")
    }
    func clearPersistedData() {
        profileManager.clearAllData()
    }
}

// MARK: - WidgetLoadingDelegate

extension ProfileVM: WidgetLoadingDelegate {

    func loadingDidStart() {
        isLoading = true
    }

    func loadingDidFinish() {
        isLoading = false
    }
}
