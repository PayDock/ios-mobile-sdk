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
        public var hint: Color
        public var icon: Color
        public var background: Color

        public init(active: Color = .defaultPrimary,
                    inactive: Color = .defaultBorder,
                    error: Color = .defaultError,
                    success: Color = .defaultSuccess,
                    text: Color = .defaultText,
                    placeholder: Color = .defaultPlaceholder,
                    hint: Color = .defaultHint,
                    icon: Color = .defaultHint,
                    background: Color = .defaultBackground) {
            self.active = active
            self.inactive = inactive
            self.error = error
            self.success = success
            self.text = text
            self.placeholder = placeholder
            self.hint = hint
            self.icon = icon
            self.background = background
        }
    }
}
