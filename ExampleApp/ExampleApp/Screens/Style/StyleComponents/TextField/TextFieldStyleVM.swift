//
//  TextFieldStyleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 11.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

class TextFieldStyleVM: ObservableObject {
    
    // MARK: - Properties
    
    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool
    let allFontNames =  UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }
    
    // MARK: - Variables
    
    private var appearance: TextFieldStylableAppearance?

    // Colors
    @Published var activeColor: Color { didSet { updateAppearance() }}
    @Published var inactiveColor: Color { didSet { updateAppearance() }}
    @Published var errorColor: Color { didSet { updateAppearance() }}
    @Published var successColor: Color { didSet { updateAppearance() }}
    @Published var textColor: Color { didSet { updateAppearance() }}
    @Published var placeholderColor: Color { didSet { updateAppearance() }}
    @Published var backgroundColor: Color { didSet { updateAppearance() }}
    
    // Dimensions
    @Published var cornerRadius: CGFloat { didSet { updateAppearance() }}
    @Published var borderWidth: CGFloat { didSet { updateAppearance() }}
    @Published var activeBorderWidth: CGFloat { didSet { updateAppearance() }}
    @Published var topPadding: CGFloat { didSet { updateAppearance() }}
    @Published var leadingPadding: CGFloat { didSet { updateAppearance() }}
    @Published var bottomPadding: CGFloat { didSet { updateAppearance() }}
    @Published var trailingPadding: CGFloat { didSet { updateAppearance() }}
    
    // Fonts
    @Published var textFont: String { didSet { updateAppearance() }}
    @Published var titleFont: String { didSet { updateAppearance() }}
    @Published var placeholderFont: String { didSet { updateAppearance() }}
    @Published var errorFont: String { didSet { updateAppearance() }}
    
    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: TextFieldStylableAppearance.self)
        
        self.activeColor = appearance?.textField.colors.active ?? .clear
        self.inactiveColor = appearance?.textField.colors.inactive ?? .clear
        self.errorColor = appearance?.textField.colors.error ?? .clear
        self.successColor = appearance?.textField.colors.success ?? .clear
        self.textColor = appearance?.textField.colors.text ?? .clear
        self.placeholderColor = appearance?.textField.colors.placeholder ?? .clear
        self.backgroundColor = appearance?.textField.colors.background ?? .clear
        
        self.cornerRadius = appearance?.textField.dimensions.cornerRadius ?? 0
        self.borderWidth = appearance?.textField.dimensions.borderWidth ?? 0
        self.activeBorderWidth = appearance?.textField.dimensions.activeBorderWidth ?? 0
        self.topPadding = appearance?.textField.dimensions.padding.top ?? 0
        self.leadingPadding = appearance?.textField.dimensions.padding.leading ?? 0
        self.bottomPadding = appearance?.textField.dimensions.padding.bottom ?? 0
        self.trailingPadding = appearance?.textField.dimensions.padding.trailing ?? 0
        
        self.textFont = appearance?.textField.fonts.text.customFont.name ?? ""
        self.titleFont = appearance?.textField.fonts.title.customFont.name ?? ""
        self.placeholderFont = appearance?.textField.fonts.placeholder.customFont.name ?? ""
        self.errorFont = appearance?.textField.fonts.error.customFont.name ?? ""
    }
    
    private func updateAppearance() {
        appearance?.textField.colors.active = activeColor
        appearance?.textField.colors.inactive = inactiveColor
        appearance?.textField.colors.error = errorColor
        appearance?.textField.colors.success = successColor
        appearance?.textField.colors.text = textColor
        appearance?.textField.colors.placeholder = placeholderColor
        appearance?.textField.colors.background = backgroundColor
        
        appearance?.textField.dimensions.cornerRadius = cornerRadius
        appearance?.textField.dimensions.borderWidth = borderWidth
        appearance?.textField.dimensions.activeBorderWidth = activeBorderWidth
        appearance?.textField.dimensions.padding.top = topPadding
        appearance?.textField.dimensions.padding.leading = leadingPadding
        appearance?.textField.dimensions.padding.bottom = bottomPadding
        appearance?.textField.dimensions.padding.trailing = trailingPadding
        
        appearance?.textField.fonts.text.customFont.name = textFont
        appearance?.textField.fonts.title.customFont.name = titleFont
        appearance?.textField.fonts.placeholder.customFont.name = placeholderFont
        appearance?.textField.fonts.error.customFont.name = errorFont

        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }
}
