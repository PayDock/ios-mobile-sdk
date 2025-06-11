//
//  AddressWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

public struct AddressWidgetAppearance {
    
    public let horizontalSpacing: CGFloat
    public let verticalSpacing: CGFloat
    public let title: Theme.TextAppearance
    public let textfield: Theme.TextFieldAppearance
    public let primaryButton: Theme.ButtonAppearance
    public let linkButton: Theme.ButtonAppearance
    public let searchDropdown: Theme.SearchDropdownAppearance
    
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
        self.textfield = textfield
        self.primaryButton = primaryButton
        self.linkButton = linkButton
        self.searchDropdown = searchDropdown
    }
}
