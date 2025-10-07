//
//  TextFieldTheme.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {

    public struct TextFieldAppearance {
        public var colors: TextFieldColors
        public var dimensions: TextFieldDimensions
        public var fonts: TextFieldFonts

        public init(colors: TextFieldColors = TextFieldColors(),
                    dimensions: TextFieldDimensions = TextFieldDimensions(),
                    fonts: TextFieldFonts = TextFieldFonts()) {
            self.colors = colors
            self.dimensions = dimensions
            self.fonts = fonts
        }
    }
}
