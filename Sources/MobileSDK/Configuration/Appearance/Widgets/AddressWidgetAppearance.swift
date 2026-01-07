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
    public var textField: Theme.TextFieldAppearance
    public var actionButton: Theme.ButtonAppearance
    public var expandSectionButton: Theme.ButtonAppearance
    public var searchDropdown: Theme.SearchDropdownAppearance

    public init(horizontalSpacing: CGFloat = GlobalTheme.shared.globalTheme.horizontalSpacing,
                verticalSpacing: CGFloat = GlobalTheme.shared.globalTheme.verticalSpacing,
                textFieldSpacing: CGFloat = GlobalTheme.shared.globalTheme.textFieldVerticalSpacing,
                title: Theme.TextAppearance = GlobalTheme.shared.globalTheme.title,
                textfield: Theme.TextFieldAppearance = GlobalTheme.shared.globalTheme.textField,
                primaryButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.actionButton,
                linkButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.expandSectionButton,
                searchDropdown: Theme.SearchDropdownAppearance = GlobalTheme.shared.globalTheme.searchDropdown) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.textFieldVerticalSpacing = textFieldSpacing
        self.title = title
        self.textField = textfield
        self.expandSectionButton = linkButton
        self.searchDropdown = searchDropdown

        // Custom
        self.actionButton = primaryButton
        self.actionButton.icon = Image(systemName: "plus.circle")
        self.actionButton.text = "Add"
    }
}
