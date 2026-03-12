//
//  Text+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 20.08.2023..
//

import SwiftUI

extension Text {

    /// Applies text attributes with a font that scales with Dynamic Type (accessibility font size).
    func applyAttributesWithScaledFont(_ attributes: TextAttributes) -> Text {
        self
            .font(attributes.customFont.scaledFont)
            .foregroundColor(attributes.textColor)
            .underline(attributes.underlineColor != .clear, color: attributes.underlineColor)
            .strikethrough(attributes.strikethroughColor != .clear, color: attributes.strikethroughColor)
            .italic(attributes.isItalic)
    }
}
