//
//  DropdownStyleVM.swift
//  ExampleApp
//
//  Created by Domagoj Grizelj on 13.06.2025..
//  Copyright © 2025 Paydock Ltd. All rights reserved.
//

import SwiftUI
import MobileSDK

class DropdownStyleVM: ObservableObject {
    
    // MARK: - Properties
    
    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool
    let allFontNames =  UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }
    
    // MARK: - Variables
    
    private var appearance: DropdownStylableAppearance?
    @Published var showResetConfirmation = false

    // Colors
    @Published var activeColor: Color = .clear { didSet { updateAppearance() }}
    @Published var inactiveColor: Color = .clear { didSet { updateAppearance() }}
    @Published var errorColor: Color = .clear { didSet { updateAppearance() }}
    @Published var successColor: Color = .clear { didSet { updateAppearance() }}
    @Published var textColor: Color = .clear { didSet { updateAppearance() }}
    @Published var placeholderColor: Color = .clear { didSet { updateAppearance() }}
    @Published var backgroundColor: Color = .clear { didSet { updateAppearance() }}
    @Published var dropdownBackgroundColor: Color = .clear { didSet { updateAppearance() }}
    @Published var dropdownListColor: Color = .clear { didSet { updateAppearance() }}
    
    // Dimensions
    @Published var cornerRadius: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var borderWidth: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var activeBorderWidth: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var topPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var leadingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var bottomPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var trailingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    
    // Fonts
    @Published var textFont: String = "" { didSet { updateAppearance() }}
    @Published var titleFont: String = "" { didSet { updateAppearance() }}
    @Published var placeholderFont: String = "" { didSet { updateAppearance() }}
    @Published var errorFont: String = "" { didSet { updateAppearance() }}
    @Published var dropdownListFont: String = "" { didSet { updateAppearance() }}

    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: DropdownStylableAppearance.self)
        syncUIToAppearance()
    }
    
    private func syncUIToAppearance() {
        self.activeColor = appearance?.searchDropdown.textField.colors.active ?? .clear
        self.inactiveColor = appearance?.searchDropdown.textField.colors.inactive ?? .clear
        self.errorColor = appearance?.searchDropdown.textField.colors.error ?? .clear
        self.successColor = appearance?.searchDropdown.textField.colors.success ?? .clear
        self.textColor = appearance?.searchDropdown.textField.colors.text ?? .clear
        self.placeholderColor = appearance?.searchDropdown.textField.colors.placeholder ?? .clear
        self.backgroundColor = appearance?.searchDropdown.textField.colors.background ?? .clear
        self.dropdownBackgroundColor = appearance?.searchDropdown.dropdown.colors.backgroundColor ?? .clear
        self.dropdownListColor = appearance?.searchDropdown.dropdown.text.listText.text.textColor ?? .clear
        
        self.cornerRadius = appearance?.searchDropdown.textField.dimensions.cornerRadius ?? 0
        self.borderWidth = appearance?.searchDropdown.textField.dimensions.borderWidth ?? 0
        self.activeBorderWidth = appearance?.searchDropdown.textField.dimensions.activeBorderWidth ?? 0
        self.topPadding = appearance?.searchDropdown.textField.dimensions.padding.top ?? 0
        self.leadingPadding = appearance?.searchDropdown.textField.dimensions.padding.leading ?? 0
        self.bottomPadding = appearance?.searchDropdown.textField.dimensions.padding.bottom ?? 0
        self.trailingPadding = appearance?.searchDropdown.textField.dimensions.padding.trailing ?? 0
        
        self.textFont = appearance?.searchDropdown.textField.fonts.text.customFont.name ?? ""
        self.titleFont = appearance?.searchDropdown.textField.fonts.title.customFont.name ?? ""
        self.placeholderFont = appearance?.searchDropdown.textField.fonts.placeholder.customFont.name ?? ""
        self.errorFont = appearance?.searchDropdown.textField.fonts.error.customFont.name ?? ""
        self.dropdownListFont = appearance?.searchDropdown.dropdown.text.listText.text.customFont.name ?? ""
    }
    
    private func updateAppearance() {
        guard var appearance = appearance else { return }
        
        appearance.searchDropdown.textField.colors.active = activeColor
        appearance.searchDropdown.textField.colors.inactive = inactiveColor
        appearance.searchDropdown.textField.colors.error = errorColor
        appearance.searchDropdown.textField.colors.success = successColor
        appearance.searchDropdown.textField.colors.text = textColor
        appearance.searchDropdown.textField.colors.placeholder = placeholderColor
        appearance.searchDropdown.textField.colors.background = backgroundColor
        appearance.searchDropdown.dropdown.colors.backgroundColor = dropdownBackgroundColor
        appearance.searchDropdown.dropdown.text.listText.text.textColor = dropdownListColor
        
        appearance.searchDropdown.textField.dimensions.cornerRadius = cornerRadius
        appearance.searchDropdown.textField.dimensions.borderWidth = borderWidth
        appearance.searchDropdown.textField.dimensions.activeBorderWidth = activeBorderWidth
        appearance.searchDropdown.textField.dimensions.padding.top = topPadding
        appearance.searchDropdown.textField.dimensions.padding.leading = leadingPadding
        appearance.searchDropdown.textField.dimensions.padding.bottom = bottomPadding
        appearance.searchDropdown.textField.dimensions.padding.trailing = trailingPadding
        
        appearance.searchDropdown.textField.fonts.text.customFont.name = textFont
        appearance.searchDropdown.textField.fonts.title.customFont.name = titleFont
        appearance.searchDropdown.textField.fonts.placeholder.customFont.name = placeholderFont
        appearance.searchDropdown.textField.fonts.error.customFont.name = errorFont
        appearance.searchDropdown.dropdown.text.listText.text.customFont.name = dropdownListFont

        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }
    
    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: DropdownStylableAppearance.self)
        
        syncUIToAppearance()
    }
}
