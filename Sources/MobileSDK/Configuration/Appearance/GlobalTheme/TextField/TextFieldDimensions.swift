//
//  TextFieldDimensions.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {

    public struct TextFieldDimensions {
        public var cornerRadius: CGFloat
        public var borderWidth: CGFloat
        public var activeBorderWidth: CGFloat
        public var padding: Padding

        public init(cornerRadius: CGFloat = .defaultTextFieldCornerRadius,
                    borderWidth: CGFloat = .defaultBorderWidth,
                    activeBorderWidth: CGFloat = .defaultBorderWidth * 2,
                    padding: Padding = Padding()) {
            self.cornerRadius = cornerRadius
            self.borderWidth = borderWidth
            self.activeBorderWidth = activeBorderWidth
            self.padding = padding
        }
    }
}
