//
//  ButtonDimensions.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation

extension Theme {

    public struct ButtonDimensions {
        public var cornerRadius: CGFloat
        public var borderWidth: CGFloat
        public var padding: Padding

        public init(cornerRadius: CGFloat = .defaultButtonCornerRadius,
                    borderWidth: CGFloat = .defaultBorderWidth,
                    padding: Padding = Padding()) {
            self.cornerRadius = cornerRadius
            self.borderWidth = borderWidth
            self.padding = padding
        }
    }
}
