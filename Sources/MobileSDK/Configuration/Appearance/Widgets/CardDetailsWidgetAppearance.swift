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

    public let title: Theme.TextAppearance
    public let textField: Theme.TextFieldAppearance
    public let actionButton: Theme.ButtonAppearance
    public let toggle: Theme.ToggleAppearance
    public let linkTheme: Theme.TextAppearance
    public let description: Theme.TextAppearance
    
    init(title: Theme.TextAppearance = Theme.TextAppearance(),
         textField: Theme.TextFieldAppearance = Theme.TextFieldAppearance(),
         actionButton: Theme.ButtonAppearance = Theme.ButtonAppearance(),
         toggle: Theme.ToggleAppearance = Theme.ToggleAppearance(),
         linkTheme: Theme.TextAppearance = Theme.TextAppearance(),
         description: Theme.TextAppearance = Theme.TextAppearance()) {
        self.title = title
        self.textField = textField
        self.actionButton = actionButton
        self.toggle = toggle
        self.linkTheme = linkTheme
        self.description = description
    }
}
