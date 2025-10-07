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
    public var title: Theme.TextAppearance
    public var textField: Theme.TextFieldAppearance
    public var actionButton: Theme.ButtonAppearance
    public var toolbarButton: Theme.ButtonAppearance

    public init(verticalSpacing: CGFloat = 6,
                horizontalSpacing: CGFloat = 16,
                title: Theme.TextAppearance = GlobalTheme.shared.globalTheme.title,
                textField: Theme.TextFieldAppearance = GlobalTheme.shared.globalTheme.textField,
                actionButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.actionButton,
                toolbarButton: Theme.ButtonAppearance = GlobalTheme.shared.globalTheme.toolbarButton) {
        self.verticalSpacing = verticalSpacing
        self.horizontalSpacing = horizontalSpacing
        self.title = title
        self.textField = textField
        self.actionButton = actionButton
        self.toolbarButton = toolbarButton
    }
}
