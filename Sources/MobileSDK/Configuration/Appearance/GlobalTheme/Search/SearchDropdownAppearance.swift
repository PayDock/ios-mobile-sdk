//
//  SearchDropdown.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {
    
    public struct SearchDropdownAppearance {
        public let textField: TextFieldAppearance
        public let dropdown: Dropdown
        
        public init(textField: TextFieldAppearance = TextFieldAppearance(),
                    dropdown: Dropdown = Dropdown()) {
            self.textField = textField
            self.dropdown = dropdown
        }
    }
}
