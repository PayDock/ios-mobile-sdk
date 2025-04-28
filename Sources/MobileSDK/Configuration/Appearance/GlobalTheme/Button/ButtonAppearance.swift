//
//  ButtonTheme.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {
    
    public struct ButtonAppearance {
        public let colors: ButtonColors
        public let dimensions: ButtonDimensions
        public let fonts: ButtonFonts
        public let loader: ButtonLoader
        
        public init(colors: ButtonColors = ButtonColors(),
                    dimensions: ButtonDimensions = ButtonDimensions(),
                    fonts: ButtonFonts = ButtonFonts(),
                    loader: ButtonLoader = ButtonLoader()) {
            self.colors = colors
            self.dimensions = dimensions
            self.fonts = fonts
            self.loader = loader
        }
    }
}
