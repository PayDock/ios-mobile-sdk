//
//  TextAttributes.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 23.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI

public struct TextAttributes {
    public var customFont: CustomFont
    public var textColor: Color
    public var isUnderlined: Bool
    public var underlineColor: Color
    public var isStrikethrough: Bool
    public var strikethroughColor: Color
    public var isItalic: Bool
    
    public init(font: CustomFont = CustomFont(name: "FFF-AcidGrotesk-Normal", size: 14.0),
                textColor: Color = .defaultText,
                isUnderlined: Bool = true,
                underlineColor: Color = .clear,
                isStrikethrough: Bool = true,
                strikethroughColor: Color = .clear,
                isItalic: Bool = false) {
        self.customFont = font
        self.textColor = textColor
        self.isUnderlined = isUnderlined
        self.underlineColor = underlineColor
        self.isStrikethrough = isStrikethrough
        self.strikethroughColor = strikethroughColor
        self.isItalic = isItalic
    }
}
