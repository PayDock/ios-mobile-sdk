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
        public var textField: TextFieldAppearance
        public var dropdown: DropdownAppearance

        public init(textField: TextFieldAppearance = TextFieldAppearance(),
                    dropdown: DropdownAppearance = DropdownAppearance()) {
            self.textField = textField
            self.dropdown = dropdown
        }
    }
}
