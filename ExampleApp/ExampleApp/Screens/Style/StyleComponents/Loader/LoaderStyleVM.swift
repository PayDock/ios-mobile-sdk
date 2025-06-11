//
//  LoaderStyleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 09.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

class LoaderStyleVM: ObservableObject {
    
    // MARK: - Properties
    
    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool
    
    // MARK: - Variables
    
    private var appearance: LoaderStylableAppearance?
    @Published var loaderColor: Color { didSet { updateAppearance() }}
    @Published var loaderOverlayColor: Color { didSet { updateAppearance() }}
    
    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: LoaderStylableAppearance.self)
        self.loaderColor = appearance?.loader.color ?? .clear
        self.loaderOverlayColor = appearance?.loader.overlayColor ?? .clear
    }
    
    private func updateAppearance() {
        appearance?.loader.color = loaderColor
        appearance?.loader.overlayColor = loaderOverlayColor
        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }
}
