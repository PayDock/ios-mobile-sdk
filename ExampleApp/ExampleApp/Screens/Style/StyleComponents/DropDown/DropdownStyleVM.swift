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

    // MARK: - Dropdown
    // Dropdown Colors
    
    @Published var dropdownBackgroundColor: Color = .clear { didSet { updateAppearance() }}
    @Published var dropdownListColor: Color = .clear { didSet { updateAppearance() }}
    
    // Dropdown Padding
    
    @Published var dropdownTopPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var dropdownLeadingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var dropdownBottomPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var dropdownTrailingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    
    // Dropdown Fonts
    
    @Published var dropdownListFont: String = "" { didSet { updateAppearance() }}
    
    // MARK: - Textfield
    // Textfield Colors
    @Published var activeColor: Color = .clear { didSet { updateAppearance() }}
    @Published var inactiveColor: Color = .clear { didSet { updateAppearance() }}
    @Published var errorColor: Color = .clear { didSet { updateAppearance() }}
    @Published var successColor: Color = .clear { didSet { updateAppearance() }}
    @Published var textColor: Color = .clear { didSet { updateAppearance() }}
    @Published var placeholderColor: Color = .clear { didSet { updateAppearance() }}
    @Published var backgroundColor: Color = .clear { didSet { updateAppearance() }}

    
    // Textfield Dimensions
    @Published var cornerRadius: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var borderWidth: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var activeBorderWidth: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var textFieldTopPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var textFieldLeadingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var textFieldBottomPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var textFieldTrailingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    
    // Textfield Fonts
    @Published var textFont: String = "" { didSet { updateAppearance() }}
    @Published var titleFont: String = "" { didSet { updateAppearance() }}
    @Published var placeholderFont: String = "" { didSet { updateAppearance() }}
    @Published var errorFont: String = "" { didSet { updateAppearance() }}


    // MARK: - Initialization
    
    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: DropdownStylableAppearance.self)
        syncUIToAppearance()
    }
    
    private func syncUIToAppearance() {
        // Dropdown
        self.dropdownBackgroundColor = appearance?.searchDropdown.dropdown.colors.backgroundColor ?? .clear
        self.dropdownListColor = appearance?.searchDropdown.dropdown.text.listText.text.textColor ?? .clear
        
        self.dropdownTopPadding = appearance?.searchDropdown.dropdown.dimensions.padding.top ?? 0
        self.dropdownLeadingPadding = appearance?.searchDropdown.dropdown.dimensions.padding.leading ?? 0
        self.dropdownBottomPadding = appearance?.searchDropdown.dropdown.dimensions.padding.bottom ?? 0
        self.dropdownTrailingPadding = appearance?.searchDropdown.dropdown.dimensions.padding.trailing ?? 0
        
        self.dropdownListFont = appearance?.searchDropdown.dropdown.text.listText.text.customFont.name ?? ""
        
        // TextField
        self.activeColor = appearance?.searchDropdown.textField.colors.active ?? .clear
        self.inactiveColor = appearance?.searchDropdown.textField.colors.inactive ?? .clear
        self.errorColor = appearance?.searchDropdown.textField.colors.error ?? .clear
        self.successColor = appearance?.searchDropdown.textField.colors.success ?? .clear
        self.textColor = appearance?.searchDropdown.textField.colors.text ?? .clear
        self.placeholderColor = appearance?.searchDropdown.textField.colors.placeholder ?? .clear
        self.backgroundColor = appearance?.searchDropdown.textField.colors.background ?? .clear
        
        self.cornerRadius = appearance?.searchDropdown.textField.dimensions.cornerRadius ?? 0
        self.borderWidth = appearance?.searchDropdown.textField.dimensions.borderWidth ?? 0
        self.activeBorderWidth = appearance?.searchDropdown.textField.dimensions.activeBorderWidth ?? 0
        
        self.textFieldTopPadding = appearance?.searchDropdown.textField.dimensions.padding.top ?? 0
        self.textFieldLeadingPadding = appearance?.searchDropdown.textField.dimensions.padding.leading ?? 0
        self.textFieldBottomPadding = appearance?.searchDropdown.textField.dimensions.padding.bottom ?? 0
        self.textFieldTrailingPadding = appearance?.searchDropdown.textField.dimensions.padding.trailing ?? 0
        
        self.textFont = appearance?.searchDropdown.textField.fonts.text.customFont.name ?? ""
        self.titleFont = appearance?.searchDropdown.textField.fonts.title.customFont.name ?? ""
        self.placeholderFont = appearance?.searchDropdown.textField.fonts.placeholder.customFont.name ?? ""
        self.errorFont = appearance?.searchDropdown.textField.fonts.error.customFont.name ?? ""
    }
    
    private func updateAppearance() {
        guard var appearance = appearance else { return }
        // Dropdown
        appearance.searchDropdown.dropdown.colors.backgroundColor = dropdownBackgroundColor
        appearance.searchDropdown.dropdown.text.listText.text.textColor = dropdownListColor
        
        appearance.searchDropdown.dropdown.dimensions.padding.top = dropdownTopPadding
        appearance.searchDropdown.dropdown.dimensions.padding.leading = dropdownLeadingPadding
        appearance.searchDropdown.dropdown.dimensions.padding.bottom = dropdownBottomPadding
        appearance.searchDropdown.dropdown.dimensions.padding.trailing = dropdownTrailingPadding
        
        appearance.searchDropdown.dropdown.text.listText.text.customFont.name = dropdownListFont
        
        // TextField
        appearance.searchDropdown.textField.colors.active = activeColor
        appearance.searchDropdown.textField.colors.inactive = inactiveColor
        appearance.searchDropdown.textField.colors.error = errorColor
        appearance.searchDropdown.textField.colors.success = successColor
        appearance.searchDropdown.textField.colors.text = textColor
        appearance.searchDropdown.textField.colors.placeholder = placeholderColor
        appearance.searchDropdown.textField.colors.background = backgroundColor
        
        appearance.searchDropdown.textField.dimensions.cornerRadius = cornerRadius
        appearance.searchDropdown.textField.dimensions.borderWidth = borderWidth
        appearance.searchDropdown.textField.dimensions.activeBorderWidth = activeBorderWidth
        
        appearance.searchDropdown.textField.dimensions.padding.top = textFieldTopPadding
        appearance.searchDropdown.textField.dimensions.padding.leading = textFieldLeadingPadding
        appearance.searchDropdown.textField.dimensions.padding.bottom = textFieldBottomPadding
        appearance.searchDropdown.textField.dimensions.padding.trailing = textFieldTrailingPadding
        
        appearance.searchDropdown.textField.fonts.text.customFont.name = textFont
        appearance.searchDropdown.textField.fonts.title.customFont.name = titleFont
        appearance.searchDropdown.textField.fonts.placeholder.customFont.name = placeholderFont
        appearance.searchDropdown.textField.fonts.error.customFont.name = errorFont

        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }
    
    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(for: selectedWidget, isDarkMode: stylingDarkMode, as: DropdownStylableAppearance.self)
        
        syncUIToAppearance()
    }
}
