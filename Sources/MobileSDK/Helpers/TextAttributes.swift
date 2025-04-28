//
//  TextAttributes.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 23.04.2025..
//

import SwiftUI

public struct TextAttributes {
    public let font: Font?
    public let textColor: Color
    public let isUnderlined: Bool
    public let underlineColor: Color?
    public let isStrikethrough: Bool
    public let strikethroughColor: Color?
    public let isItalic: Bool
    
    public init(font: Font? = nil,
         textColor: Color = .defaultText,
         isUnderlined: Bool = false,
         underlineColor: Color? = nil,
         isStrikethrough: Bool = false,
         strikethroughColor: Color? = nil,
         isItalic: Bool = false) {
        self.font = font
        self.textColor = textColor
        self.isUnderlined = isUnderlined
        self.underlineColor = underlineColor
        self.isStrikethrough = isStrikethrough
        self.strikethroughColor = strikethroughColor
        self.isItalic = isItalic
    }
}
