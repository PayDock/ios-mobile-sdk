//
//  AddressWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

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

    public init(horizontalSpacing: CGFloat = 16,
                verticalSpacing: CGFloat = 16,
                textFieldSpacing: CGFloat = 8,
                title: Theme.TextAppearance = GlobalTheme.shared.globalTheme.title,
                textfield: Theme.TextFieldAppearance = GlobalTheme.shared.globalTheme.textField,
                primaryButton: Theme.ButtonAppearance = .init(
                    icon: Image(systemName: "plus.circle"),
                    text: "Add"),
                linkButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.expandSectionButton,
                searchDropdown: Theme.SearchDropdownAppearance = GlobalTheme.shared.globalTheme.searchDropdown) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.textFieldVerticalSpacing = textFieldSpacing
        self.title = title
        self.textField = textfield
        self.actionButton = primaryButton
        self.expandSectionButton = linkButton
        self.searchDropdown = searchDropdown
    }
}
