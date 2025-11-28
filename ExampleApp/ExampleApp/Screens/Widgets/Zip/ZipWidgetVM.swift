//
//  ZipWidgetVM.swift
//  ExampleApp
//
//  Copyright © 2024 Paydock Ltd.
//

import SwiftUI
import MobileSDK

@MainActor
class ZipWidgetVM: ObservableObject {

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isLoading = false

    // MARK: - Initialisation

    init() {}

    // MARK: - Configuration

    func createZipConfig() -> ZipConfig {
        return ZipConfig(
            gatewayId: ProjectEnvironment.shared.getZipGatewayId() ?? "",
            token: ProjectEnvironment.shared.getWidgetAccessToken(),
            amount: 17,
            currency: "AUD",
            orderReference: "ORDER-\(UUID().uuidString.prefix(8))",
            orderItems: [
                ZipConfig.OrderItem(
                    name: "Demo Product",
                    amount: 50.00,
                    quantity: 1,
                    type: "physical",
                    reference: "ITEM-001"
                )
            ],
            shopper: ZipConfig.Shopper(
                firstName: "JP",
                lastName: "Costello",
                email: "john.doe@example.com",
                phone: "+1234567890"
            ),
            billing: ZipConfig.Address(
                firstName: "JP",
                lastName: "Costello",
                line1: "123 Main Street",
                city: "VIC",
                state: "NSW",
                postalCode: "4001",
                countryCode: "AU"
            ),
            environment: .sandbox
        )
    }

    // MARK: - Handlers

    func handleError(error: ZipError) {
        alertTitle = "Error"
        alertMessage = error.customMessage
        showAlert = true
    }

    func handleSuccess(ottToken: String) {
        alertTitle = "Success"
        alertMessage = "OTT token created! Token: \(ottToken)"
        showAlert = true
    }
}

// MARK: - WidgetLoadingDelegate

extension ZipWidgetVM: WidgetLoadingDelegate {
    func loadingDidStart() {
        isLoading = true
    }

    func loadingDidFinish() {
        isLoading = false
    }
}
