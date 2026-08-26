//
//  TextFieldStyleVM.swift
//  ExampleApp
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI
import MobileSDK

class TextFieldStyleVM: ObservableObject {

    // MARK: - Properties

    private let selectedWidget: WidgetsEnum
    private let stylingDarkMode: Bool
    private let cardTextFieldKeyPath: WritableKeyPath<CardDetailsWidgetAppearance, Theme.TextFieldAppearance>?
    // Per-field overrides on GiftCard/Address are optional (nil falls back to the base `textField`).
    private let giftCardTextFieldKeyPath: WritableKeyPath<GiftCardWidgetAppearance, Theme.TextFieldAppearance?>?
    private let addressTextFieldKeyPath: WritableKeyPath<AddressWidgetAppearance, Theme.TextFieldAppearance?>?
    let allFontNames =  UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }

    // MARK: - Variables

    private var appearance: Any?
    @Published var showResetConfirmation = false

    // Colors
    @Published var activeColor: Color = .clear { didSet { updateAppearance() }}
    @Published var inactiveColor: Color = .clear { didSet { updateAppearance() }}
    @Published var errorColor: Color = .clear { didSet { updateAppearance() }}
    @Published var successColor: Color = .clear { didSet { updateAppearance() }}
    @Published var textColor: Color = .clear { didSet { updateAppearance() }}
    @Published var placeholderColor: Color = .clear { didSet { updateAppearance() }}
    @Published var hintColor: Color = .clear { didSet { updateAppearance() }}
    @Published var iconColor: Color = .clear { didSet { updateAppearance() }}
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

    @Published var hintUnderlineColor: Color = .clear { didSet { updateAppearance() }}
    @Published var hintStrikethroughColor: Color = .clear { didSet { updateAppearance() }}
    @Published var hintFont: String = "" { didSet { updateAppearance() }}
    @Published var hintFontSize: CGFloat = 0.0 { didSet { updateAppearance() }}

    // Text Content
    @Published var placeholderText: String = "" { didSet { updateAppearance() }}
    @Published var hintText: String = "" { didSet { updateAppearance() }}
    @Published var accessibilityHintText: String = "" { didSet { updateAppearance() }}

    // Message Padding
    @Published var messageTopPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var messageLeadingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var messageBottomPadding: CGFloat = 0.0 { didSet { updateAppearance() }}
    @Published var messageTrailingPadding: CGFloat = 0.0 { didSet { updateAppearance() }}

    // MARK: - Initialization

    init(selectedWidget: WidgetsEnum,
         stylingDarkMode: Bool,
         cardTextFieldKeyPath: WritableKeyPath<CardDetailsWidgetAppearance, Theme.TextFieldAppearance>? = nil,
         giftCardTextFieldKeyPath: WritableKeyPath<GiftCardWidgetAppearance, Theme.TextFieldAppearance?>? = nil,
         addressTextFieldKeyPath: WritableKeyPath<AddressWidgetAppearance, Theme.TextFieldAppearance?>? = nil) {
        self.selectedWidget = selectedWidget
        self.stylingDarkMode = stylingDarkMode
        self.cardTextFieldKeyPath = cardTextFieldKeyPath
        self.giftCardTextFieldKeyPath = giftCardTextFieldKeyPath
        self.addressTextFieldKeyPath = addressTextFieldKeyPath

        self.appearance = TextFieldStyleVM.loadAppearance(
            for: selectedWidget,
            stylingDarkMode: stylingDarkMode,
            cardTextFieldKeyPath: cardTextFieldKeyPath,
            giftCardTextFieldKeyPath: giftCardTextFieldKeyPath,
            addressTextFieldKeyPath: addressTextFieldKeyPath)
        syncUIToAppearance()
    }

    /// Loads the concrete appearance when a per-field keyPath is supplied, otherwise the generic
    /// `TextFieldStylableAppearance` (base `textField`) for the widget.
    private static func loadAppearance(
        for selectedWidget: WidgetsEnum,
        stylingDarkMode: Bool,
        cardTextFieldKeyPath: WritableKeyPath<CardDetailsWidgetAppearance, Theme.TextFieldAppearance>?,
        giftCardTextFieldKeyPath: WritableKeyPath<GiftCardWidgetAppearance, Theme.TextFieldAppearance?>?,
        addressTextFieldKeyPath: WritableKeyPath<AddressWidgetAppearance, Theme.TextFieldAppearance?>?) -> Any? {
        if selectedWidget == .card, cardTextFieldKeyPath != nil {
            return StyleThemeManager.getAppearance(
                for: selectedWidget, isDarkMode: stylingDarkMode, as: CardDetailsWidgetAppearance.self)
        } else if giftCardTextFieldKeyPath != nil {
            return StyleThemeManager.getAppearance(
                for: selectedWidget, isDarkMode: stylingDarkMode, as: GiftCardWidgetAppearance.self)
        } else if addressTextFieldKeyPath != nil {
            return StyleThemeManager.getAppearance(
                for: selectedWidget, isDarkMode: stylingDarkMode, as: AddressWidgetAppearance.self)
        } else {
            return StyleThemeManager.getAppearance(
                for: selectedWidget, isDarkMode: stylingDarkMode, as: TextFieldStylableAppearance.self)
        }
    }

    private func syncUIToAppearance() {
        guard let textField = getCurrentTextField() else { return }

        self.activeColor = textField.colors.active
        self.inactiveColor = textField.colors.inactive
        self.errorColor = textField.colors.error
        self.successColor = textField.colors.success
        self.textColor = textField.colors.text
        self.placeholderColor = textField.colors.placeholder
        self.hintColor = textField.colors.hint
        self.iconColor = textField.colors.icon
        self.backgroundColor = textField.colors.background

        self.cornerRadius = textField.dimensions.cornerRadius
        self.borderWidth = textField.dimensions.borderWidth
        self.activeBorderWidth = textField.dimensions.activeBorderWidth
        self.topPadding = textField.dimensions.padding.top
        self.leadingPadding = textField.dimensions.padding.leading
        self.bottomPadding = textField.dimensions.padding.bottom
        self.trailingPadding = textField.dimensions.padding.trailing

        self.textUnderlineColor = textField.fonts.text.underlineColor
        self.textStrikethroughColor = textField.fonts.text.strikethroughColor
        self.textFont = textField.fonts.text.customFont.fontName
        self.textFontSize = textField.fonts.text.customFont.size

        self.titleUnderlineColor = textField.fonts.title.underlineColor
        self.titleStrikethroughColor = textField.fonts.title.strikethroughColor
        self.titleFont = textField.fonts.title.customFont.fontName
        self.titleFontSize = textField.fonts.title.customFont.size

        self.placeholderUnderlineColor = textField.fonts.placeholder.underlineColor
        self.placeholderStrikethroughColor = textField.fonts.placeholder.strikethroughColor
        self.placeholderFont = textField.fonts.placeholder.customFont.fontName
        self.placeholderFontSize = textField.fonts.placeholder.customFont.size

        self.errorUnderlineColor = textField.fonts.error.underlineColor
        self.errorStrikethroughColor = textField.fonts.error.strikethroughColor
        self.errorFont = textField.fonts.error.customFont.fontName
        self.errorFontSize = textField.fonts.error.customFont.size

        self.hintUnderlineColor = textField.fonts.hint.underlineColor
        self.hintStrikethroughColor = textField.fonts.hint.strikethroughColor
        self.hintFont = textField.fonts.hint.customFont.fontName
        self.hintFontSize = textField.fonts.hint.customFont.size

        self.placeholderText = textField.placeholderText ?? ""
        self.hintText = textField.hintText ?? ""
        self.accessibilityHintText = textField.accessibilityHintText ?? ""

        self.messageTopPadding = textField.dimensions.messagePadding.top
        self.messageLeadingPadding = textField.dimensions.messagePadding.leading
        self.messageBottomPadding = textField.dimensions.messagePadding.bottom
        self.messageTrailingPadding = textField.dimensions.messagePadding.trailing
    }

    // MARK: - Helper Methods

    /// Gets the current text field appearance based on widget type and keyPath.
    /// For the optional GiftCard/Address overrides, falls back to the base `textField` so the editor
    /// opens showing the effective values.
    private func getCurrentTextField() -> Theme.TextFieldAppearance? {
        if let cardAppearance = appearance as? CardDetailsWidgetAppearance,
           let keyPath = cardTextFieldKeyPath {
            return cardAppearance[keyPath: keyPath]
        } else if let giftAppearance = appearance as? GiftCardWidgetAppearance,
                  let keyPath = giftCardTextFieldKeyPath {
            return giftAppearance[keyPath: keyPath] ?? giftAppearance.textField
        } else if let addressAppearance = appearance as? AddressWidgetAppearance,
                  let keyPath = addressTextFieldKeyPath {
            return addressAppearance[keyPath: keyPath] ?? addressAppearance.textField
        } else if let textFieldAppearance = appearance as? TextFieldStylableAppearance {
            return textFieldAppearance.textField
        }
        return nil
    }

    private func updateAppearance() {
        // Handle CardDetailsWidgetAppearance with a specific (non-optional) text field.
        if var cardAppearance = appearance as? CardDetailsWidgetAppearance,
           let keyPath = cardTextFieldKeyPath {
            updateTextField(&cardAppearance[keyPath: keyPath])
            StyleThemeManager.setAppearance(cardAppearance, for: selectedWidget, isDarkMode: stylingDarkMode)
            self.appearance = cardAppearance
        }
        // Handle GiftCard per-field override (optional keyPath).
        else if var giftAppearance = appearance as? GiftCardWidgetAppearance,
                let keyPath = giftCardTextFieldKeyPath {
            var field = giftAppearance[keyPath: keyPath] ?? giftAppearance.textField
            updateTextField(&field)
            giftAppearance[keyPath: keyPath] = field
            StyleThemeManager.setAppearance(giftAppearance, for: selectedWidget, isDarkMode: stylingDarkMode)
            self.appearance = giftAppearance
        }
        // Handle Address per-field override (optional keyPath).
        else if var addressAppearance = appearance as? AddressWidgetAppearance,
                let keyPath = addressTextFieldKeyPath {
            var field = addressAppearance[keyPath: keyPath] ?? addressAppearance.textField
            updateTextField(&field)
            addressAppearance[keyPath: keyPath] = field
            StyleThemeManager.setAppearance(addressAppearance, for: selectedWidget, isDarkMode: stylingDarkMode)
            self.appearance = addressAppearance
        }
        // Handle the generic base `textField`.
        else if var textFieldAppearance = appearance as? TextFieldStylableAppearance {
            updateTextField(&textFieldAppearance.textField)
            StyleThemeManager.setAppearance(textFieldAppearance, for: selectedWidget, isDarkMode: stylingDarkMode)
            self.appearance = textFieldAppearance
        }
    }

    /// Updates the text field appearance with current values
    private func updateTextField(_ textField: inout Theme.TextFieldAppearance) {
        textField.colors.active = activeColor
        textField.colors.inactive = inactiveColor
        textField.colors.error = errorColor
        textField.colors.success = successColor
        textField.colors.text = textColor
        textField.colors.placeholder = placeholderColor
        textField.colors.hint = hintColor
        textField.colors.icon = iconColor
        textField.colors.background = backgroundColor

        textField.dimensions.cornerRadius = cornerRadius
        textField.dimensions.borderWidth = borderWidth
        textField.dimensions.activeBorderWidth = activeBorderWidth
        textField.dimensions.padding.top = topPadding
        textField.dimensions.padding.leading = leadingPadding
        textField.dimensions.padding.bottom = bottomPadding
        textField.dimensions.padding.trailing = trailingPadding

        textField.fonts.text.underlineColor = textUnderlineColor
        textField.fonts.text.strikethroughColor = textStrikethroughColor
        textField.fonts.text.customFont.type = .custom(name: textFont)
        textField.fonts.text.customFont.size = textFontSize

        textField.fonts.title.underlineColor = titleUnderlineColor
        textField.fonts.title.strikethroughColor = titleStrikethroughColor
        textField.fonts.title.customFont.type = .custom(name: titleFont)
        textField.fonts.title.customFont.size = titleFontSize

        textField.fonts.placeholder.underlineColor = placeholderUnderlineColor
        textField.fonts.placeholder.strikethroughColor = placeholderStrikethroughColor
        textField.fonts.placeholder.customFont.type = .custom(name: placeholderFont)
        textField.fonts.placeholder.customFont.size = placeholderFontSize

        textField.fonts.error.underlineColor = errorUnderlineColor
        textField.fonts.error.strikethroughColor = errorStrikethroughColor
        textField.fonts.error.customFont.type = .custom(name: errorFont)
        textField.fonts.error.customFont.size = errorFontSize

        textField.fonts.hint.underlineColor = hintUnderlineColor
        textField.fonts.hint.strikethroughColor = hintStrikethroughColor
        textField.fonts.hint.customFont.type = .custom(name: hintFont)
        textField.fonts.hint.customFont.size = hintFontSize

        textField.placeholderText = placeholderText.isEmpty ? nil : placeholderText
        textField.hintText = hintText.isEmpty ? nil : hintText
        textField.accessibilityHintText = accessibilityHintText.isEmpty ? nil : accessibilityHintText

        textField.dimensions.messagePadding.top = messageTopPadding
        textField.dimensions.messagePadding.leading = messageLeadingPadding
        textField.dimensions.messagePadding.bottom = messageBottomPadding
        textField.dimensions.messagePadding.trailing = messageTrailingPadding
    }

    func resetAppearance() {
        StyleThemeManager.resetAppearance(for: selectedWidget, isDarkMode: stylingDarkMode)

        self.appearance = TextFieldStyleVM.loadAppearance(
            for: selectedWidget,
            stylingDarkMode: stylingDarkMode,
            cardTextFieldKeyPath: cardTextFieldKeyPath,
            giftCardTextFieldKeyPath: giftCardTextFieldKeyPath,
            addressTextFieldKeyPath: addressTextFieldKeyPath)

        syncUIToAppearance()
    }
}
