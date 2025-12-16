//
//  PayPalVaultExampleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 24.10.2024..
//  Copyright © 2024 Paydock Ltd. All rights reserved.
//

import Foundation
import MobileSDK
import OSLog

class PayPalVaultExampleVM: ObservableObject {

    // MARK: - Dependencies

    private let configManager: ConfigManager

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isLoading = false

    init(configManager: ConfigManager = .shared) {
        self.configManager = configManager
    }

    // MARK: - Config

    func getConfig() -> PayPalVaultConfig {
        return configManager.getPayPalVaultConfig()
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

// MARK: - WidgetLoadingDelegate

extension PayPalVaultExampleVM: WidgetLoadingDelegate {

    func loadingDidStart() {
        isLoading = true
    }

    func loadingDidFinish() {
        isLoading = false
    }
}

// MARK: - WidgetEventDelegate

extension PayPalVaultExampleVM: WidgetEventDelegate {

    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
