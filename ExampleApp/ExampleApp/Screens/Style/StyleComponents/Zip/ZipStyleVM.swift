//
//  ZipStyleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

class ZipStyleVM: ObservableObject {

    // MARK: - Properties

    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool

    private(set) var buttonStyles: [ZipButtonStyle] = [
        .whiteOnBlack,
        .blackOnWhite
    ]

    private(set) var buttonStyleNames: [String] = [
        "White on Black",
        "Black on White"
    ]

    // MARK: - Variables

    private var appearance: ZipWidgetAppearance?
    @Published var showResetConfirmation = false

    @Published var buttonStyle: ZipButtonStyle = .whiteOnBlack { didSet { updateAppearance() }}

    @Published var selectedButtonStyleName: String = "White on Black" {
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
            as: ZipWidgetAppearance.self)
        syncUIToAppearance()
    }

    private func syncUIToAppearance() {
        self.buttonStyle = appearance?.buttonStyle ?? .whiteOnBlack

        // Sync string properties
        if let styleIndex = buttonStyles.firstIndex(of: buttonStyle) {
            selectedButtonStyleName = buttonStyleNames[styleIndex]
        }
    }

    private func updateAppearance() {
        guard var appearance = appearance else { return }

        appearance.buttonStyle = buttonStyle

        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }

    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: ZipWidgetAppearance.self)

        syncUIToAppearance()
    }
}
