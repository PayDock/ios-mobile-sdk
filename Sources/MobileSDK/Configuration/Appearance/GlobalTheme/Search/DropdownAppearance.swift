//
//  Dropdown.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {

    public struct DropdownAppearance {
        public var colors: DropdownColors
        public var dimensions: DropdownDimensions
        public var text: DropdownText

        public init(colors: DropdownColors = DropdownColors(),
                    dimensions: DropdownDimensions = DropdownDimensions(),
                    text: DropdownText = DropdownText()) {
            self.colors = colors
            self.dimensions = dimensions
            self.text = text
        }
    }
}
