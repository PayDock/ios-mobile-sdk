//
//  TextFieldAppearance.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

extension Theme {

    public struct TextFieldAppearance {
        public var colors: TextFieldColors
        public var dimensions: TextFieldDimensions
        public var fonts: TextFieldFonts
        public var placeholderText: String?
        public var hintText: String?
        public var accessibilityHintText: String?

        public init(colors: TextFieldColors = TextFieldColors(),
                    dimensions: TextFieldDimensions = TextFieldDimensions(),
                    fonts: TextFieldFonts = TextFieldFonts(),
                    placeholderText: String? = nil,
                    hintText: String? = nil,
                    accessibilityHintText: String? = nil) {
            self.colors = colors
            self.dimensions = dimensions
            self.fonts = fonts
            self.placeholderText = placeholderText
            self.hintText = hintText
            self.accessibilityHintText = accessibilityHintText
        }
    }
}
