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
    public var textFieldVerticalSpacing: CGFloat = 8.0
    public var title: Theme.TextAppearance
    public var textField: Theme.TextFieldAppearance
    public var actionButton: Theme.ButtonAppearance
    public var toolbarButton: Theme.ButtonAppearance

    public init(verticalSpacing: CGFloat = GlobalTheme.shared.globalTheme.verticalSpacing,
                horizontalSpacing: CGFloat = GlobalTheme.shared.globalTheme.horizontalSpacing,
                textFieldVerticalSpacing: CGFloat = GlobalTheme.shared.globalTheme.textFieldVerticalSpacing,
                title: Theme.TextAppearance = GlobalTheme.shared.globalTheme.title,
                textField: Theme.TextFieldAppearance = GlobalTheme.shared.globalTheme.textField,
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
        self.actionButton = actionButton
        self.toolbarButton = toolbarButton
    }
}
