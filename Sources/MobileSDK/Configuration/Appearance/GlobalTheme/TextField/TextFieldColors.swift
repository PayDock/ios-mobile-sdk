//
//  TextFieldColors.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 24.04.2025..
//  Copyright © 2024 Paydock Ltd.
//

import Foundation
import SwiftUI

extension Theme {

    public struct TextFieldColors {
        public var active: Color
        public var inactive: Color
        public var error: Color
        public var success: Color
        public var text: Color
        public var placeholder: Color
        public var background: Color

        public init(active: Color = .defaultPrimary,
                    inactive: Color = .defaultBorder,
                    error: Color = .defaultError,
                    success: Color = .defaultSuccess,
                    text: Color = .defaultText,
                    placeholder: Color = .defaultPlaceholder,
                    background: Color = .defaultBackground) {
            self.active = active
            self.inactive = inactive
            self.error = error
            self.success = success
            self.text = text
            self.placeholder = placeholder
            self.background = background
        }
    }
}
