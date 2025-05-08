//
//  GiftCardWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

public struct GiftCardWidgetAppearance {
    public let title: Theme.TextAppearance
    public let textField: Theme.TextFieldAppearance
    public let actionButton: Theme.ButtonAppearance
    public let toolbarButton: Theme.ButtonAppearance
    
    public init(title: Theme.TextAppearance = Theme.TextAppearance(),
                textField: Theme.TextFieldAppearance = Theme.TextFieldAppearance(),
                actionButton: Theme.ButtonAppearance = Theme.ButtonAppearance(dimensions: .init(padding: .init(top: 16))),
                toolbarButton: Theme.ButtonAppearance = Theme.ButtonAppearance(colors: .init(background: .clear, text: .primaryColor, border: .clear))) {
        self.title = title
        self.textField = textField
        self.actionButton = actionButton
        self.toolbarButton = toolbarButton
    }
}
