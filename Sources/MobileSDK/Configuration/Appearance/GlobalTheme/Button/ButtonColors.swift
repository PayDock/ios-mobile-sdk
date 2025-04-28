//
//  ButtonColors.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 18.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import SwiftUI

extension Theme {
    
    public struct ButtonColors {
        public let background: Color
        public let text: Color
        public let image: Color
        public let border: Color
        public let opacity: Double
        
        public init(background: Color = .defaultPrimary,
                    text: Color = .defaultOnPrimary,
                    image: Color = .defaultOnPrimary,
                    border: Color = .defaultPrimary,
                    opacity: Double = 1.0) {
            self.background = background
            self.text = text
            self.image = image
            self.border = border
            self.opacity = opacity
        }
    }
}
