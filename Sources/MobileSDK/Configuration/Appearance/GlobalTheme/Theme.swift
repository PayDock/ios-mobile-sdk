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
    public let search: SearchDropdownAppearance
    public let actionButton: ButtonAppearance
    public let expandSectionButton: ButtonAppearance
    public let loader: OverlayLoaderAppearance
    public let toggle: ToggleAppearance
    public let link: TextAppearance
    public let description: TextAppearance
    public let title: TextAppearance
    
    public init(textField: TextFieldAppearance = TextFieldAppearance(),
                search: SearchDropdownAppearance = SearchDropdownAppearance(),
                actionButton: ButtonAppearance = ButtonAppearance(),
                expandSectionButton: ButtonAppearance = ButtonAppearance(colors: .init(background: .defaultBackground, text: .primary, border: .clear)),
                loader: OverlayLoaderAppearance = OverlayLoaderAppearance(),
                toggle: ToggleAppearance = ToggleAppearance(),
                link: TextAppearance = TextAppearance(text: .init(textColor: .defaultPrimary)),
                description: TextAppearance = TextAppearance(),
                title: TextAppearance = TextAppearance()) {
        self.textField = textField
        self.search = search
        self.actionButton = actionButton
        self.expandSectionButton = expandSectionButton
        self.loader = loader
        self.toggle = toggle
        self.link = link
        self.description = description
        self.title = title
    }
}
