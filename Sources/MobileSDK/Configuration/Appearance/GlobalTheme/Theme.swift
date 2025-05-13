//
//  Theme.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

public struct Theme {
    
    public let textField: TextFieldAppearance
    public let searchDropdown: SearchDropdownAppearance
    public let actionButton: ButtonAppearance
    public let expandSectionButton: ButtonAppearance
    public let toolbarButton: ButtonAppearance
    public let loader: OverlayLoaderAppearance
    public let toggle: ToggleAppearance
    public let link: TextAppearance
    public let description: TextAppearance
    public let title: TextAppearance
    
    public init(textField: TextFieldAppearance = TextFieldAppearance(),
                searchDropdown: SearchDropdownAppearance = SearchDropdownAppearance(),
                actionButton: ButtonAppearance = ButtonAppearance(dimensions: .init(padding: .init(top: 16))),
                expandSectionButton: Theme.ButtonAppearance = Theme.ButtonAppearance(
                    colors: .init(background: .defaultBackground, text: .primaryColor, border: .clear),
                    fonts: .init(title: .init(isUnderlined: true))),
                toolbarButton: ButtonAppearance = ButtonAppearance(colors: .init(background: .clear, text: .primary, border: .clear)),
                loader: OverlayLoaderAppearance = OverlayLoaderAppearance(),
                toggle: ToggleAppearance = ToggleAppearance(),
                link: TextAppearance = TextAppearance(text: .init(textColor: .defaultPrimary)),
                description: TextAppearance = TextAppearance(),
                title: TextAppearance = TextAppearance(text: TextAttributes(font: .init(size: 16.0)), padding: .init(bottom: 20.0))) {
        self.textField = textField
        self.searchDropdown = searchDropdown
        self.actionButton = actionButton
        self.expandSectionButton = expandSectionButton
        self.toolbarButton = toolbarButton
        self.loader = loader
        self.toggle = toggle
        self.link = link
        self.description = description
        self.title = title
    }
}
