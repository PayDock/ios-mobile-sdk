//
//  AddressExampleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import MobileSDK
import OSLog

@MainActor
class AddressExampleVM: ObservableObject {

    // MARK: - Dependencies

    private let configManager: ConfigManager

    // MARK: - Properties

    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""

    // MARK: - Initialisation

    init(configManager: ConfigManager = .shared) {
        self.configManager = configManager
    }

    // MARK: - Config

    func getConfig() -> AddressWidgetConfig {
        return configManager.getAddressConfig()
    }

    func getAppearance(isDarkMode: Bool) -> AddressWidgetAppearance {
        let appearance = StyleThemeManager.getAppearance(
            for: .address,
            isDarkMode: isDarkMode,
            as: AddressWidgetAppearance.self,
            shouldCreateDefaultIfNeeded: false)
        return appearance ?? AddressWidgetAppearance()
    }

    // MARK: - Handle Callback

    func handleAddressCompletion(_ address: Address) {
        alertTitle = "Address"
        alertMessage = """
        \(address.firstName) \(address.lastName)
        \(address.addressLine1)
        \(address.addressLine2)
        \(address.city)
        \(address.state)
        \(address.postcode)
        \(address.country)
        """
        showAlert = true
    }
}

// MARK: - WidgetEventDelegate

extension AddressExampleVM: WidgetEventDelegate {
    func widgetEvent(event: WidgetEvent) {
        os_log(.info, "Widget event received: \(event.jsonDescription)")
    }
}
