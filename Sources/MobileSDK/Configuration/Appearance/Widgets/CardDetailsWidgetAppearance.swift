//
//  CardDetailsWidgetAppearance.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

public struct CardDetailsWidgetAppearance:
    ToggleStylableAppearance,
    ActionButtonStylableAppearance,
    ToolbarButtonStylableAppearance,
    LinkTextStylableAppearance,
    ToggleTextStylableAppearance,
    SpacingStylableAppearance {

    public var verticalSpacing: CGFloat
    public var horizontalSpacing: CGFloat
    public var textFieldVerticalSpacing: CGFloat
    public var cardNameTextField: Theme.TextFieldAppearance
    public var cardNumberTextField: Theme.TextFieldAppearance
    public var cardExpiryTextField: Theme.TextFieldAppearance
    public var cardSecurityTextField: Theme.TextFieldAppearance
    public var actionButton: Theme.ButtonAppearance
    public var toolbarButton: Theme.ButtonAppearance
    public var toggle: Theme.ToggleAppearance
    public var toggleText: Theme.TextAppearance
    public var linkText: Theme.TextAppearance

    public init(verticalSpacing: CGFloat = GlobalTheme.shared.globalTheme.verticalSpacing,
                horizontalSpacing: CGFloat = GlobalTheme.shared.globalTheme.horizontalSpacing,
                textFieldVerticalSpacing: CGFloat = GlobalTheme.shared.globalTheme.textFieldVerticalSpacing,
                cardNameTextField: Theme.TextFieldAppearance = {
                    var defaults = GlobalTheme.shared.globalTheme.textField
                    defaults.hintText = "Enter your cardholder name"
                    return defaults
                }(),
                cardNumberTextField: Theme.TextFieldAppearance = {
                    var defaults = GlobalTheme.shared.globalTheme.textField
                    defaults.placeholderText = "XXXX XXXX XXXX XXXX"
                    defaults.hintText = "Enter your card number"
                    return defaults
                }(),
                cardExpiryTextField: Theme.TextFieldAppearance = {
                    var defaults = GlobalTheme.shared.globalTheme.textField
                    defaults.placeholderText = "MM/YY"
                    defaults.hintText = "Format MM / YY"
                    return defaults
                }(),
                cardSecurityTextField: Theme.TextFieldAppearance = {
                    var defaults = GlobalTheme.shared.globalTheme.textField
                    defaults.placeholderText = "XXX"
                    defaults.hintText = "Enter your security code"
                    return defaults
                }(),
                actionButton: Theme.ButtonAppearance = {
                    var defaults = GlobalTheme.shared.globalTheme.actionButton
                    defaults.text = "Submit"
                    return defaults
                }(),
                toolbarButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.toolbarButton,
                toggle: Theme.ToggleAppearance = GlobalTheme.shared.globalTheme.toggle,
                toggleText: Theme.TextAppearance = GlobalTheme.shared.globalTheme.toggleText,
                linkText: Theme.TextAppearance = GlobalTheme.shared.globalTheme.linkText) {
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.textFieldVerticalSpacing = textFieldVerticalSpacing
        self.cardNameTextField = cardNameTextField
        self.cardNumberTextField = cardNumberTextField
        self.cardExpiryTextField = cardExpiryTextField
        self.cardSecurityTextField = cardSecurityTextField
        self.actionButton = actionButton
        self.toolbarButton = toolbarButton
        self.toggle = toggle
        self.toggleText = toggleText
        self.linkText = linkText
    }
}
