//
//  ButtonColors.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import SwiftUI

extension Theme {

    public struct ButtonColors {
        public var background: Color
        public var text: Color
        public var image: Color
        public var border: Color
        public var disabledOpacity: Double

        public init(background: Color = .defaultPrimary,
                    text: Color = .defaultOnPrimary,
                    image: Color = .defaultOnPrimary,
                    border: Color = .clear,
                    disabledOpacity: Double = 0.8) {
            self.background = background
            self.text = text
            self.image = image
            self.border = border
            self.disabledOpacity = disabledOpacity
        }
    }
}
