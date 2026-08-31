//
//  GiftCardWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

public struct GiftCardWidgetAppearance:
    ActionButtonStylableAppearance,
    ToolbarButtonStylableAppearance,
    TextFieldStylableAppearance,
    TitleStylableAppearance,
    SpacingStylableAppearance {

    public var verticalSpacing: CGFloat
    public var horizontalSpacing: CGFloat
    public var textFieldVerticalSpacing: CGFloat
    public var title: Theme.TextAppearance
    /// Base appearance applied to every text field. Per-field overrides below fall back to this when `nil`.
    public var textField: Theme.TextFieldAppearance
    /// Optional per-field override for the card-number field. Falls back to `textField` when `nil`.
    public var cardNumberTextField: Theme.TextFieldAppearance?
    /// Optional per-field override for the PIN field. Falls back to `textField` when `nil`.
    public var pinTextField: Theme.TextFieldAppearance?
    public var actionButton: Theme.ButtonAppearance
    public var toolbarButton: Theme.ButtonAppearance

    public init(verticalSpacing: CGFloat = GlobalTheme.shared.globalTheme.verticalSpacing,
                horizontalSpacing: CGFloat = GlobalTheme.shared.globalTheme.horizontalSpacing,
                textFieldVerticalSpacing: CGFloat = GlobalTheme.shared.globalTheme.textFieldVerticalSpacing,
                title: Theme.TextAppearance = GlobalTheme.shared.globalTheme.title,
                textField: Theme.TextFieldAppearance = GlobalTheme.shared.globalTheme.textField,
                // Seed the default placeholder/hint strings into the per-field appearance so they
                // are discoverable and editable via the appearance object (e.g. shown in the
                // styling screen) rather than living only as fallbacks inside the widget.
                cardNumberTextField: Theme.TextFieldAppearance? = {
                    var defaults = GlobalTheme.shared.globalTheme.textField
                    defaults.placeholderText = "XXXX XXXX XXXX XXXX"
                    defaults.hintText = "Enter your gift card number"
                    return defaults
                }(),
                pinTextField: Theme.TextFieldAppearance? = {
                    var defaults = GlobalTheme.shared.globalTheme.textField
                    defaults.placeholderText = "XXXX"
                    defaults.hintText = "Enter your 4-digit PIN"
                    return defaults
                }(),
                actionButton: Theme.ButtonAppearance = {
                    var defaults = GlobalTheme.shared.globalTheme.actionButton
                    defaults.icon = Image(systemName: "plus.circle")
                    defaults.text = "Add"
                    return defaults
                }(),
                toolbarButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.toolbarButton) {
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.textFieldVerticalSpacing = textFieldVerticalSpacing
        self.title = title
        self.textField = textField
        self.cardNumberTextField = cardNumberTextField
        self.pinTextField = pinTextField
        self.actionButton = actionButton
        self.toolbarButton = toolbarButton
    }
}
