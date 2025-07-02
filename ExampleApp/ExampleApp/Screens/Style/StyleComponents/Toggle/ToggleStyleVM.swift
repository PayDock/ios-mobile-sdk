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
    @Published var showResetConfirmation = false
    @Published var activeColor: Color = .clear { didSet { updateAppearance() }}
        
    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: ToggleStylableAppearance.self)
        syncUIToAppearance()
    }
    
    private func syncUIToAppearance() {
        self.activeColor = appearance?.toggle.activeColor ?? .clear
    }
    
    private func updateAppearance() {
        appearance?.toggle.activeColor = activeColor
        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }
    
    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: ToggleStylableAppearance.self)
        
        syncUIToAppearance()
    }
}
