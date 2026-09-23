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

    // MARK: - Pre-presentation validation hook

    var validationMode: ApplePayValidationMode {
        configManager.getApplePayConfigParams().validationMode
    }

    /// `nil` when no callback should be attached, otherwise the fake validation below.
    var presentationHook: ApplePayPresentationDecision? {
        guard validationMode != .none else { return nil }
        return { [weak self] in await self?.shouldPresentPaymentSheet() ?? true }
    }

    /// Fake app-side validation passed to `ApplePayWidget(onShouldPresentPaymentSheet:)`.
    func shouldPresentPaymentSheet() async -> Bool {
        isLoading = true
        try? await Task.sleep(nanoseconds: 1_000_000_000) // simulate a network call
        isLoading = false

        guard validationMode != .fail else {
            alertTitle = "Blocked by validation"
            alertMessage = "App-side validation returned false, so the SDK did not present the Apple Pay sheet " +
                "and did not call the completion handler."
            showAlert = true
            return false
        }
        return true
    }

    // MARK: - Handle Callbacks

    func handleError(error: ApplePayError) {
        Task { @MainActor in
            isLoading = false
            alertTitle = "Error"
            alertMessage = "\(error.customMessage)"
            showAlert = true
        }
    }

    func handleSuccess(data: ApplePayResult) {
        Task { @MainActor in
            alertTitle = "Success"
            alertMessage = "OTT Token received:\n\(data.ottToken)"
            showAlert = true
        }
    }
}

// MARK: - WidgetEventDelegate

extension ApplePayExampleVM: WidgetEventDelegate {

    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
