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
    @Published var showResetConfirmation = false

    // Colors
    @Published var activeColor: Color = .clear { didSet { updateAppearance() }}
    @Published var inactiveColor: Color = .clear { didSet { updateAppearance() }}
    @Published var errorColor: Color = .clear { didSet { updateAppearance() }}
    @Published var successColor: Color = .clear { didSet { updateAppearance() }}
    @Published var textColor: Color = .clear { didSet { updateAppearance() }}
    @Published var placeholderColor: Color = .clear { didSet { updateAppearance() }}
    @Published var backgroundColor: Color = .clear { didSet { updateAppearance() }}

    // Dimensions
    @Published var cornerRadius: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var borderWidth: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var activeBorderWidth: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var topPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var leadingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var bottomPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var trailingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}

    // Fonts
    @Published var textUnderlineColor: Color = .clear { didSet { updateAppearance() }}
    @Published var textStrikethroughColor: Color = .clear { didSet { updateAppearance() }}
    @Published var textFont: String = "" { didSet { updateAppearance() }}
    @Published var textFontSize: CGFloat = 0.0 { didSet { updateAppearance() }}

    @Published var titleUnderlineColor: Color = .clear { didSet { updateAppearance() }}
    @Published var titleStrikethroughColor: Color = .clear { didSet { updateAppearance() }}
    @Published var titleFont: String = "" { didSet { updateAppearance() }}
    @Published var titleFontSize: CGFloat = 0.0 { didSet { updateAppearance() }}

    @Published var placeholderUnderlineColor: Color = .clear { didSet { updateAppearance() }}
    @Published var placeholderStrikethroughColor: Color = .clear { didSet { updateAppearance() }}
    @Published var placeholderFont: String = "" { didSet { updateAppearance() }}
    @Published var placeholderFontSize: CGFloat = 0.0 { didSet { updateAppearance() }}

    @Published var errorUnderlineColor: Color = .clear { didSet { updateAppearance() }}
    @Published var errorStrikethroughColor: Color = .clear { didSet { updateAppearance() }}
    @Published var errorFont: String = "" { didSet { updateAppearance() }}
    @Published var errorFontSize: CGFloat = 0.0 { didSet { updateAppearance() }}

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: TextFieldStylableAppearance.self)
        syncUIToAppearance()
    }

    private func syncUIToAppearance() {
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

        self.textUnderlineColor = appearance?.textField.fonts.text.underlineColor ?? .clear
        self.textStrikethroughColor = appearance?.textField.fonts.text.strikethroughColor ?? .clear
        self.textFont = appearance?.textField.fonts.text.customFont.name ?? ""
        self.textFontSize = appearance?.textField.fonts.text.customFont.size ?? 0.0

        self.titleUnderlineColor = appearance?.textField.fonts.title.underlineColor ?? .clear
        self.titleStrikethroughColor = appearance?.textField.fonts.title.strikethroughColor ?? .clear
        self.titleFont = appearance?.textField.fonts.title.customFont.name ?? ""
        self.titleFontSize = appearance?.textField.fonts.title.customFont.size ?? 0.0

        self.placeholderUnderlineColor = appearance?.textField.fonts.placeholder.underlineColor ?? .clear
        self.placeholderStrikethroughColor = appearance?.textField.fonts.placeholder.strikethroughColor ?? .clear
        self.placeholderFont = appearance?.textField.fonts.placeholder.customFont.name ?? ""
        self.placeholderFontSize = appearance?.textField.fonts.placeholder.customFont.size ?? 0.0

        self.errorUnderlineColor = appearance?.textField.fonts.error.underlineColor ?? .clear
        self.errorStrikethroughColor = appearance?.textField.fonts.error.strikethroughColor ?? .clear
        self.errorFont = appearance?.textField.fonts.error.customFont.name ?? ""
        self.errorFontSize = appearance?.textField.fonts.error.customFont.size ?? 0.0
    }

    private func updateAppearance() {
        guard var appearance = appearance else { return }

        appearance.textField.colors.active = activeColor
        appearance.textField.colors.inactive = inactiveColor
        appearance.textField.colors.error = errorColor
        appearance.textField.colors.success = successColor
        appearance.textField.colors.text = textColor
        appearance.textField.colors.placeholder = placeholderColor
        appearance.textField.colors.background = backgroundColor

        appearance.textField.dimensions.cornerRadius = cornerRadius
        appearance.textField.dimensions.borderWidth = borderWidth
        appearance.textField.dimensions.activeBorderWidth = activeBorderWidth
        appearance.textField.dimensions.padding.top = topPadding
        appearance.textField.dimensions.padding.leading = leadingPadding
        appearance.textField.dimensions.padding.bottom = bottomPadding
        appearance.textField.dimensions.padding.trailing = trailingPadding

        appearance.textField.fonts.text.underlineColor = textUnderlineColor
        appearance.textField.fonts.text.strikethroughColor = textStrikethroughColor
        appearance.textField.fonts.text.customFont.name = textFont
        appearance.textField.fonts.text.customFont.size = textFontSize

        appearance.textField.fonts.title.underlineColor = titleUnderlineColor
        appearance.textField.fonts.title.strikethroughColor = titleStrikethroughColor
        appearance.textField.fonts.title.customFont.name = titleFont
        appearance.textField.fonts.title.customFont.size = titleFontSize

        appearance.textField.fonts.placeholder.underlineColor = placeholderUnderlineColor
        appearance.textField.fonts.placeholder.strikethroughColor = placeholderStrikethroughColor
        appearance.textField.fonts.placeholder.customFont.name = placeholderFont
        appearance.textField.fonts.placeholder.customFont.size = placeholderFontSize

        appearance.textField.fonts.error.underlineColor = errorUnderlineColor
        appearance.textField.fonts.error.strikethroughColor = errorStrikethroughColor
        appearance.textField.fonts.error.customFont.name = errorFont
        appearance.textField.fonts.error.customFont.size = errorFontSize

        StyleThemeManager.setAppearance(appearance, for: selectedWidget, isDarkMode: stylingDarkMode)
    }

    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)
        self.appearance = StyleThemeManager.getAppearance(
            for: selectedWidget,
            isDarkMode: stylingDarkMode,
            as: TextFieldStylableAppearance.self)

        syncUIToAppearance()
    }
}
