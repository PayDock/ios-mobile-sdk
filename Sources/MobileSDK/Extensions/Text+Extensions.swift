//
//  Text+Extensions.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 20.08.2023..
//

import SwiftUI

extension Text {

    func customFont(_ size: Fonts.Size) -> Text {
        font(.custom(Appearance.shared.fontName, size: size.rawValue))
    }
    
    func applyAttributes(_ attributes: TextAttributes) -> Text {
        self
            .font(attributes.font)
            .foregroundColor(attributes.textColor)
            .underline(attributes.isUnderlined, color: attributes.underlineColor)
            .strikethrough(attributes.isStrikethrough, color: attributes.strikethroughColor)
            .italic(attributes.isItalic)
    }
}
