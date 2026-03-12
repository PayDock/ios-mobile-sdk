//
//  CardDetailsExampleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import MobileSDK
import OSLog

@MainActor
class CardDetailsExampleVM: ObservableObject {

    // MARK: - Dependencies

    private let configManager: ConfigManager

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    init(configManager: ConfigManager = .shared) {
        self.configManager = configManager
    }

    // MARK: - Config

    func getConfig() -> CardDetailsWidgetConfig {
        return configManager.getCardDetailsConfig()
    }

    func getAppearance(isDarkMode: Bool) -> CardDetailsWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .card,
            isDarkMode: isDarkMode,
            as: CardDetailsWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? CardDetailsWidgetAppearance()
    }

    // MARK: - Completion handling

    func handleSuccess(_ result: CardResult) {
        alertTitle = "Success"
        alertMessage = result.token
        showAlert = true
    }

    func handleError(_ error: CardDetailsError) {
        alertTitle = "Error"
        alertMessage = error.customMessage
        showAlert = true
    }
}

// MARK: - WidgetEventDelegate

extension CardDetailsExampleVM: WidgetEventDelegate {

    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
