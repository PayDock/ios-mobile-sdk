//
//  ApplePayStyleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 23.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK
import PassKit

class ApplePayStyleVM: ObservableObject {

    // MARK: - Properties

    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool
    private(set) var buttonTypes: [PKPaymentButtonType] = [
        .plain,
        .buy,
        .setUp,
        .inStore,
        .donate,
        .checkout,
        .book,
        .subscribe,
        .reload,
        .addMoney,
        .topUp,
        .order,
        .rent,
        .support,
        .contribute,
        .tip
    ]
    private(set) var buttonStyles: [PKPaymentButtonStyle] = [
        .automatic,
        .white,
        .whiteOutline,
        .black
    ]

    private(set) var buttonTypeNames: [String] = [
        "Plain",
        "Buy",
        "Set Up",
        "In Store",
        "Donate",
        "Checkout",
        "Book",
        "Subscribe",
        "Reload",
        "Add Money",
        "Top Up",
        "Order",
        "Rent",
        "Support",
        "Contribute",
        "Tip"
    ]

    private(set) var buttonStyleNames: [String] = [
        "Automatic",
        "White",
        "White Outline",
        "Black"
    ]

    // MARK: - Variables

    private var appearance: ApplePayWidgetAppearance?
    @Published var showResetConfirmation = false

    @Published var buttonType: PKPaymentButtonType = .plain { didSet { updateAppearance() }}
    @Published var buttonStyle: PKPaymentButtonStyle = .automatic { didSet { updateAppearance() }}

    @Published var selectedButtonTypeName: String = "Plain" {
        didSet {
            if let index = buttonTypeNames.firstIndex(of: selectedButtonTypeName) {
                buttonType = buttonTypes[index]
            }
        }
    }

    @Published var selectedButtonStyleName: String = "Automatic" {
        didSet {
            if let index = buttonStyleNames.firstIndex(of: selectedButtonStyleName) {
                buttonStyle = buttonStyles[index]
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
            as: ApplePayWidgetAppearance.self)
        syncUIToAppearance()
    }

    private func syncUIToAppearance() {
        self.buttonType = appearance?.type ?? .plain
        self.buttonStyle = appearance?.style ?? .automatic

        if let typeIndex = buttonTypes.firstIndex(of: buttonType) {
            selectedButtonTypeName = buttonTypeNames[typeIndex]
        }

        if let styleIndex = buttonStyles.firstIndex(of: buttonStyle) {
            selectedButtonStyleName = buttonStyleNames[styleIndex]
        }
    }

    private func updateAppearance() {
        guard var appearance = appearance else { return }

        appearance.type = buttonType
        appearance.style = buttonStyle

        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }

    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: ApplePayWidgetAppearance.self)

        syncUIToAppearance()
    }
}
