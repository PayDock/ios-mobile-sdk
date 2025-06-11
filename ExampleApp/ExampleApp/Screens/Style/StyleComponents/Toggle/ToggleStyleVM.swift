//
//  ToggleStyleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 10.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

class ToggleStyleVM: ObservableObject {
    
    // MARK: - Properties
    
    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool
    
    // MARK: - Variables
    
    private var appearance: ToggleStylableAppearance?
    @Published var activeColor: Color { didSet { updateAppearance() }}
    
    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: ToggleStylableAppearance.self)
        self.activeColor = appearance?.toggle.activeColor ?? .clear
    }
    
    private func updateAppearance() {
        appearance?.toggle.activeColor = activeColor
        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }
}
