//
//  ButtonLoaderStyleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 24.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

class ButtonLoaderStyleVM: ObservableObject {

    // MARK: - Properties

    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool

    // MARK: - Variables

    private var appearance: ActionButtonLoaderStylableAppearance?
    @Published var showResetConfirmation = false
    @Published var loaderColor: Color = .clear { didSet { updateAppearance() }}

    @Published var hasChanges = false

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: ActionButtonLoaderStylableAppearance.self)
        syncUIToAppearance()
    }

    private func syncUIToAppearance() {
        self.loaderColor = appearance?.loader.spinnerColor ?? .clear
    }

    private func updateAppearance() {
        guard var appearance = appearance else { return }

        appearance.loader.spinnerColor = loaderColor
        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }

    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: ActionButtonLoaderStylableAppearance.self)

        syncUIToAppearance()
    }
}
