//
//  CardDetailsWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

public struct CardDetailsWidgetAppearance:
    ToggleStylableAppearance,
    ActionButtonStylableAppearance,
    ToolbarButtonStylableAppearance,
    TextFieldStylableAppearance,
    TitleStylableAppearance,
    LinkTextStylableAppearance,
    ToggleTextStylableAppearance,
    SpacingStylableAppearance {

    public var verticalSpacing: CGFloat
    public var horizontalSpacing: CGFloat
    public var textFieldVerticalSpacing: CGFloat
    public var title: Theme.TextAppearance
    public var textField: Theme.TextFieldAppearance
    public var actionButton: Theme.ButtonAppearance
    public var toolbarButton: Theme.ButtonAppearance
    public var toggle: Theme.ToggleAppearance
    public var toggleText: Theme.TextAppearance
    public var linkText: Theme.TextAppearance

    public init(verticalSpacing: CGFloat = GlobalTheme.shared.globalTheme.verticalSpacing,
                horizontalSpacing: CGFloat = GlobalTheme.shared.globalTheme.horizontalSpacing,
                textFieldVerticalSpacing: CGFloat = GlobalTheme.shared.globalTheme.textFieldVerticalSpacing,
                title: Theme.TextAppearance = GlobalTheme.shared.globalTheme.title,
                textField: Theme.TextFieldAppearance = GlobalTheme.shared.globalTheme.textField,
                actionButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.actionButton,
                toolbarButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.toolbarButton,
                toggle: Theme.ToggleAppearance = GlobalTheme.shared.globalTheme.toggle,
                toggleText: Theme.TextAppearance = GlobalTheme.shared.globalTheme.toggleText,
                linkText: Theme.TextAppearance = GlobalTheme.shared.globalTheme.linkText) {
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.textFieldVerticalSpacing = textFieldVerticalSpacing
        self.title = title
        self.textField = textField
        self.toolbarButton = toolbarButton
        self.toggle = toggle
        self.toggleText = toggleText
        self.linkText = linkText

        // Custom
        self.actionButton = actionButton
        self.actionButton.text = "Submit"
    }
}
