//
//  AddressWidgetAppearance.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

public struct AddressWidgetAppearance:
    ActionButtonStylableAppearance,
    ExpandSectionButtonStylableAppearance,
    TextFieldStylableAppearance,
    DropdownStylableAppearance,
    TitleStylableAppearance,
    SpacingStylableAppearance {

    public var horizontalSpacing: CGFloat
    public var verticalSpacing: CGFloat
    public var textFieldVerticalSpacing: CGFloat
    public var title: Theme.TextAppearance
    /// Base appearance applied to every text field. Per-field overrides below fall back to this when `nil`.
    public var textField: Theme.TextFieldAppearance
    /// Optional per-field overrides. Each falls back to `textField` when `nil`.
    public var firstNameTextField: Theme.TextFieldAppearance?
    public var lastNameTextField: Theme.TextFieldAppearance?
    public var addressLine1TextField: Theme.TextFieldAppearance?
    public var addressLine2TextField: Theme.TextFieldAppearance?
    public var cityTextField: Theme.TextFieldAppearance?
    public var stateTextField: Theme.TextFieldAppearance?
    public var postcodeTextField: Theme.TextFieldAppearance?
    public var actionButton: Theme.ButtonAppearance
    public var expandSectionButton: Theme.ButtonAppearance
    public var searchDropdown: Theme.SearchDropdownAppearance

    public init(horizontalSpacing: CGFloat = GlobalTheme.shared.globalTheme.horizontalSpacing,
                verticalSpacing: CGFloat = GlobalTheme.shared.globalTheme.verticalSpacing,
                textFieldVerticalSpacing: CGFloat = GlobalTheme.shared.globalTheme.textFieldVerticalSpacing,
                title: Theme.TextAppearance = GlobalTheme.shared.globalTheme.title,
                textField: Theme.TextFieldAppearance = GlobalTheme.shared.globalTheme.textField,
                firstNameTextField: Theme.TextFieldAppearance? = nil,
                lastNameTextField: Theme.TextFieldAppearance? = nil,
                addressLine1TextField: Theme.TextFieldAppearance? = nil,
                addressLine2TextField: Theme.TextFieldAppearance? = nil,
                cityTextField: Theme.TextFieldAppearance? = nil,
                stateTextField: Theme.TextFieldAppearance? = nil,
                postcodeTextField: Theme.TextFieldAppearance? = nil,
                actionButton: Theme.ButtonAppearance = {
                    var defaults = GlobalTheme.shared.globalTheme.actionButton
                    defaults.icon = Image(systemName: "plus.circle")
                    defaults.text = "Add"
                    return defaults
                }(),
                expandSectionButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.expandSectionButton,
                searchDropdown: Theme.SearchDropdownAppearance = GlobalTheme.shared.globalTheme.searchDropdown) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.textFieldVerticalSpacing = textFieldVerticalSpacing
        self.title = title
        self.textField = textField
        self.firstNameTextField = firstNameTextField
        self.lastNameTextField = lastNameTextField
        self.addressLine1TextField = addressLine1TextField
        self.addressLine2TextField = addressLine2TextField
        self.cityTextField = cityTextField
        self.stateTextField = stateTextField
        self.postcodeTextField = postcodeTextField
        self.actionButton = actionButton
        self.expandSectionButton = expandSectionButton
        self.searchDropdown = searchDropdown
    }
}
