//
//  SpacingsStyleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 24.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

class SpacingsStyleVM: ObservableObject {

    // MARK: - Properties

    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool

    // MARK: - Variables

    private var appearance: SpacingStylableAppearance?
    @Published var showResetConfirmation = false
    @Published var horizontalSpacing: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var verticalSpacing: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var textFieldVerticalSpacing: CGFloat = 0.0 { didSet { updateAppearance() }}

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: SpacingStylableAppearance.self)
        syncUIToAppearance()
    }

    private func syncUIToAppearance() {
        self.horizontalSpacing = appearance?.horizontalSpacing ?? 0.0
        self.verticalSpacing = appearance?.verticalSpacing ?? 0.0
        self.textFieldVerticalSpacing = appearance?.textFieldVerticalSpacing ?? 0.0
    }

    private func updateAppearance() {
        guard var appearance = appearance else { return }

        appearance.horizontalSpacing = horizontalSpacing
        appearance.verticalSpacing = verticalSpacing
        appearance.textFieldVerticalSpacing = textFieldVerticalSpacing

        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }

    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: SpacingStylableAppearance.self)

        syncUIToAppearance()
    }
}
