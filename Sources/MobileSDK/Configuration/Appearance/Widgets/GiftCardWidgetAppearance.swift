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
    
    init(title: Theme.TextAppearance = Theme.TextAppearance(),
         textField: Theme.TextFieldAppearance = Theme.TextFieldAppearance(),
         actionButton: Theme.ButtonAppearance = Theme.ButtonAppearance()) {
        self.title = title
        self.textField = textField
        self.actionButton = actionButton
    }
}
