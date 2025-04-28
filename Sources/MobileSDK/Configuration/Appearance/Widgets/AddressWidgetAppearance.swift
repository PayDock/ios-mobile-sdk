//
//  AddressWidgetAppearance.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

public struct AddressWidgetAppearance {
    public let title: Theme.TextAppearance
    public let textfield: Theme.TextFieldAppearance
    public let primaryButton: Theme.ButtonAppearance
    public let expandSectionButton: Theme.ButtonAppearance
    public let search: Theme.SearchDropdownAppearance
    
    init(title: Theme.TextAppearance = Theme.TextAppearance(),
         textfield: Theme.TextFieldAppearance = Theme.TextFieldAppearance(),
         primaryButton: Theme.ButtonAppearance = Theme.ButtonAppearance(),
         expandSectionButton:Theme.ButtonAppearance = Theme.ButtonAppearance(),
         search: Theme.SearchDropdownAppearance = Theme.SearchDropdownAppearance()) {
        self.title = title
        self.textfield = textfield
        self.primaryButton = primaryButton
        self.expandSectionButton = expandSectionButton
        self.search = search
    }
}
