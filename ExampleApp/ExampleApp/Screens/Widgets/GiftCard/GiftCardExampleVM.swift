//
//  GiftCardExampleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import MobileSDK
import OSLog

@MainActor
class GiftCardExampleVM: ObservableObject {

    // MARK: - Dependencies

    private let configManager: ConfigManager

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    // Demo of `loadingDelegate` — the signal a host uses to show its own loading UI when driving
    // submission externally (`config.showSubmitButton = false`). See `GiftCardExampleView`'s
    // "Add Gift Card (custom button)".
    @Published var isSubmitting = false

    // MARK: - Initialisation

    init(configManager: ConfigManager = .shared) {
        self.configManager = configManager
    }

    // MARK: - Config

    func getConfig() -> GiftCardWidgetConfig {
        return configManager.getGiftCardConfig()
    }

    func getAppearance(isDarkMode: Bool) -> GiftCardWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .giftCard,
            isDarkMode: isDarkMode,
            as: GiftCardWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? GiftCardWidgetAppearance()
    }

    // MARK: - Completion handling

    func handleSuccess(_ result: GiftCardResult) {
        alertTitle = "Success"
        alertMessage = result.token
        showAlert = true
    }

    func handleError(_ error: GiftCardError) {
        alertTitle = "Error"
        alertMessage = error.customMessage
        showAlert = true
    }
}

// MARK: - WidgetEventDelegate

extension GiftCardExampleVM: WidgetEventDelegate {

    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}

// MARK: - WidgetLoadingDelegate

extension GiftCardExampleVM: WidgetLoadingDelegate {

    func loadingDidStart() {
        isSubmitting = true
    }

    func loadingDidFinish() {
        isSubmitting = false
    }
}
