//
//  CardDetailsWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

public struct CardDetailsWidgetAppearance {

    public let verticalSpacing: CGFloat
    public let horizontalSpacing: CGFloat
    public let title: Theme.TextAppearance
    public let textField: Theme.TextFieldAppearance
    public let actionButton: Theme.ButtonAppearance
    public let toolbarButton: Theme.ButtonAppearance
    public let toggle: Theme.ToggleAppearance
    public let toggleText: Theme.TextAppearance
    public let linkText: Theme.TextAppearance
    
    public init(verticalSpacing: CGFloat = 6,
                horizontalSpacing: CGFloat = 16,
                title: Theme.TextAppearance = GlobalTheme.shared.globalTheme.title,
                textField: Theme.TextFieldAppearance = GlobalTheme.shared.globalTheme.textField,
                actionButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.actionButton,
                toolbarButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.toolbarButton,
                toggle: Theme.ToggleAppearance = GlobalTheme.shared.globalTheme.toggle,
                toggleText: Theme.TextAppearance = GlobalTheme.shared.globalTheme.toggleText,
                linkText: Theme.TextAppearance = GlobalTheme.shared.globalTheme.linkText) {
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.title = title
        self.textField = textField
        self.actionButton = actionButton
        self.toolbarButton = toolbarButton
        self.toggle = toggle
        self.toggleText = toggleText
        self.linkText = linkText
    }
}
