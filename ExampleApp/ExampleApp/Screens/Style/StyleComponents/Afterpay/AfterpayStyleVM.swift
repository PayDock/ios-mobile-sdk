//
//  AfterpayStyleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK
import Afterpay

class AfterpayStyleVM: ObservableObject {

    // MARK: - Properties

    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool

    private(set) var buttonTypes: [ButtonKind] = [
        .buyNow,
        .checkout,
        .payNow,
        .continueWith
    ]

    private(set) var colorSchemes: [Afterpay.ColorScheme] = [
        .static(.alt),
        .static(.default),
        .static(.darkMono),
        .static(.lightMono)
    ]

    private(set) var buttonTypeNames: [String] = [
        "Buy Now",
        "Checkout",
        "Pay Now",
        "Place Order"
    ]

    private(set) var colorSchemeNames: [String] = [
        "Black on Mint",
        "Mint on Black",
        "White on Black",
        "Black on White"
    ]

    // MARK: - Variables

    private var appearance: AfterpayWidgetAppearance?
    @Published var showResetConfirmation = false

    @Published var colorScheme: Afterpay.ColorScheme = .static(.default) { didSet { updateAppearance() }}
    @Published var buttonType: ButtonKind = .buyNow { didSet { updateAppearance() }}

    @Published var selectedButtonTypeName: String = "Buy Now" {
        didSet {
            if let index = buttonTypeNames.firstIndex(of: selectedButtonTypeName) {
                buttonType = buttonTypes[index]
            }
        }
    }

    @Published var selectedColorSchemeName: String = "Black on Mint" {
        didSet {
            if let index = colorSchemeNames.firstIndex(of: selectedColorSchemeName) {
                colorScheme = colorSchemes[index]
            }
        }
    }

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: AfterpayWidgetAppearance.self)
        syncUIToAppearance()
    }

    private func syncUIToAppearance() {
        self.colorScheme = appearance?.colorScheme ?? .static(.default)
        self.buttonType = appearance?.type ?? .buyNow

        // Sync string properties
        if let typeIndex = buttonTypes.firstIndex(of: buttonType) {
            selectedButtonTypeName = buttonTypeNames[typeIndex]
        }

        // For color scheme, we need to match the static cases
        if let schemeIndex = colorSchemes.firstIndex(where: { scheme in
            switch (scheme, colorScheme) {
            case (.static(let palette1), .static(let palette2)):
                return palette1 == palette2
            default:
                return false
            }
        }) {
            selectedColorSchemeName = colorSchemeNames[schemeIndex]
        }
    }

    private func updateAppearance() {
        guard var appearance = appearance else { return }

        appearance.colorScheme = colorScheme
        appearance.type = buttonType

        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }

    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: AfterpayWidgetAppearance.self)

        syncUIToAppearance()
    }
}
