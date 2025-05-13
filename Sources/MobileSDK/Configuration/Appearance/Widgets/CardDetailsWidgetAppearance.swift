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
                title: Theme.TextAppearance = Theme.TextAppearance(text: TextAttributes(font: .init(size: 16.0)), padding: .init(bottom: 20.0)),
                textField: Theme.TextFieldAppearance = Theme.TextFieldAppearance(),
                actionButton: Theme.ButtonAppearance = Theme.ButtonAppearance(dimensions: .init(padding: .init(top: 16))),
                toolbarButton: Theme.ButtonAppearance = Theme.ButtonAppearance(colors: .init(background: .clear, text: .primaryColor, border: .clear)),
                toggle: Theme.ToggleAppearance = Theme.ToggleAppearance(),
                toggleText: Theme.TextAppearance = Theme.TextAppearance(text: .init(font: .init(size: 14))),
                linkText: Theme.TextAppearance = Theme.TextAppearance(text:
                        .init(font: .init(size: 14), textColor: .defaultPrimary, isUnderlined: true, underlineColor: .defaultPrimary))) {
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
