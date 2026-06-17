//
//  TextFieldDimensions.swift
//  MobileSDK
//
//  Copyright © 2026 Paydock Ltd.

import Foundation
import SwiftUI

extension Theme {

    public struct TextFieldDimensions {
        public var cornerRadius: CGFloat
        public var borderWidth: CGFloat
        public var activeBorderWidth: CGFloat
        public var padding: EdgeInsets
        public var messagePadding: EdgeInsets

        public init(cornerRadius: CGFloat = .defaultTextFieldCornerRadius,
                    borderWidth: CGFloat = .defaultBorderWidth,
                    activeBorderWidth: CGFloat = .defaultBorderWidth * 2,
                    padding: EdgeInsets = EdgeInsets(),
                    messagePadding: EdgeInsets = EdgeInsets()) {
            self.cornerRadius = cornerRadius
            self.borderWidth = borderWidth
            self.activeBorderWidth = activeBorderWidth
            self.padding = padding
            self.messagePadding = messagePadding
        }
    }
}
