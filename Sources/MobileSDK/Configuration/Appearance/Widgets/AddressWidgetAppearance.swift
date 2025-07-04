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
    public var title: Theme.TextAppearance
    public var textField: Theme.TextFieldAppearance
    public var actionButton: Theme.ButtonAppearance
    public var expandSectionButton: Theme.ButtonAppearance
    public var searchDropdown: Theme.SearchDropdownAppearance
    
    public init(horizontalSpacing: CGFloat = 16.0,
                verticalSpacing: CGFloat = 8.0,
                title: Theme.TextAppearance = GlobalTheme.shared.globalTheme.title,
                textfield: Theme.TextFieldAppearance = GlobalTheme.shared.globalTheme.textField,
                primaryButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.actionButton,
                linkButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.expandSectionButton,
                searchDropdown: Theme.SearchDropdownAppearance = GlobalTheme.shared.globalTheme.searchDropdown) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.title = title
        self.textField = textfield
        self.actionButton = primaryButton
        self.expandSectionButton = linkButton
        self.searchDropdown = searchDropdown
    }
}
