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
        public var colors: ButtonColors
        public var dimensions: ButtonDimensions
        public var fonts: ButtonFonts
        public var loader: ButtonLoader
        
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
