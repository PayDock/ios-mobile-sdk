//
//  ZipExampleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

@MainActor
class ZipExampleVM: ObservableObject {

    // MARK: - Properties

    private let configManager = ConfigManager.shared

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isLoading = false

    // MARK: - Configuration

    func getConfig() -> ZipWidgetConfig {
        return configManager.getZipConfig()
    }

    func getAppearance(isDarkMode: Bool) -> ZipWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .zip,
            isDarkMode: isDarkMode,
            as: ZipWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? ZipWidgetAppearance()
    }

    // MARK: - Handle callbacks

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

extension ZipExampleVM: WidgetLoadingDelegate {
    func loadingDidStart() {
        isLoading = true
    }

    func loadingDidFinish() {
        isLoading = false
    }
}
