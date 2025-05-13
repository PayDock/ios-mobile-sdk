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
                title: Theme.TextAppearance = Theme.TextAppearance(text: TextAttributes(font: .init(size: 16.0)), padding: .init(bottom: 20.0)),
                textfield: Theme.TextFieldAppearance = Theme.TextFieldAppearance(),
                primaryButton: Theme.ButtonAppearance = Theme.ButtonAppearance(),
                linkButton: Theme.ButtonAppearance = Theme.ButtonAppearance(
                    colors: .init(background: .defaultBackground, text: .primaryColor, border: .clear),
                    fonts: .init(title: .init(isUnderlined: true))),
                searchDropdown: Theme.SearchDropdownAppearance = Theme.SearchDropdownAppearance()) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.title = title
        self.textfield = textfield
        self.primaryButton = primaryButton
        self.linkButton = linkButton
        self.searchDropdown = searchDropdown
    }
}
