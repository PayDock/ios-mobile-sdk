//
//  ButtonTheme.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

extension Theme {

    public struct ButtonAppearance {
        public var colors: ButtonColors
        public var dimensions: ButtonDimensions
        public var fonts: ButtonFonts
        public var loader: ButtonLoader
        public var icon: Image?
        public var text: String
        public var accessibilityHint: String?

        public init(colors: ButtonColors = ButtonColors(),
                    dimensions: ButtonDimensions = ButtonDimensions(),
                    fonts: ButtonFonts = ButtonFonts(),
                    loader: ButtonLoader = ButtonLoader(),
                    icon: Image? = nil,
                    text: String = "",
                    accessibilityHint: String? = nil) {
            self.colors = colors
            self.dimensions = dimensions
            self.fonts = fonts
            self.loader = loader
            self.icon = icon
            self.text = text
            self.accessibilityHint = accessibilityHint
        }
    }
}
