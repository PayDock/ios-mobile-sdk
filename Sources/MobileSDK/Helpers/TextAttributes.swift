//
//  TextAttributes.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 23.04.2025..
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI

public struct TextAttributes {
    public let customFont: CustomFont
    public let textColor: Color
    public let isUnderlined: Bool
    public let underlineColor: Color?
    public let isStrikethrough: Bool
    public let strikethroughColor: Color?
    public let isItalic: Bool
    
    public init(font: CustomFont = CustomFont(name: "FFF-AcidGrotesk-Normal", size: 14.0),
                textColor: Color = .defaultText,
                isUnderlined: Bool = false,
                underlineColor: Color? = nil,
                isStrikethrough: Bool = false,
                strikethroughColor: Color? = nil,
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
