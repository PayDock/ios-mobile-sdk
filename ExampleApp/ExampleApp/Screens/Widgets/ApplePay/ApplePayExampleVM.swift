//
//  ApplePayExampleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd. All rights reserved.

import Foundation
import MobileSDK
import NetworkingLib
import OSLog
import PassKit

@MainActor
class ApplePayExampleVM: NSObject, ObservableObject {

    // MARK: - Dependencies

    private let configManager: ConfigManager

    // MARK: - Properties

    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    // MARK: - Initialisation

    init(configManager: ConfigManager = .shared) {
        self.configManager = configManager
    }

    // MARK: - Config

    func getConfig() -> ApplePayWidgetConfig {
        return configManager.getApplePayWidgetConfig()
    }

    func getAppearance(isDarkMode: Bool) -> ApplePayWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .applePay,
            isDarkMode: isDarkMode,
            as: ApplePayWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? ApplePayWidgetAppearance()
    }

    // MARK: - Handle Callbacks

    func handleError(error: ApplePayError) {
        isLoading = false
        alertTitle = "Error"
        alertMessage = "\(error.customMessage)"
        showAlert = true
    }

    func handleSuccess(data: ApplePayResult) {
        alertTitle = "Success"
        alertMessage = "OTT Token received:\n\(data.ottToken)"
        showAlert = true
    }
}

// MARK: - WidgetEventDelegate

extension ApplePayExampleVM: WidgetEventDelegate {

    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
