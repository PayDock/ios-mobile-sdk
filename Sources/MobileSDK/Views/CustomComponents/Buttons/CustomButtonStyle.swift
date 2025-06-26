//
//  CustomButtonStyle.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 05.05.2025..
//  Copyright © 2024 Paydock Ltd.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {

    let appearance: Theme.ButtonAppearance
    var isDisabled: Bool = false
    
    init(appearance: Theme.ButtonAppearance,
         isDisabled: Bool = false) {
        self.appearance = appearance
        self.isDisabled = isDisabled
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        let currentForegroundColor = isDisabled || configuration.isPressed ? appearance.colors.text.opacity(0.3) : appearance.colors.text
        let currentBorderColor = isDisabled || configuration.isPressed ? appearance.colors.border.opacity(0.3) : appearance.colors.border
        
        return configuration.label
            .font(appearance.fonts.title.customFont.font)
            .imageScale(.small)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .frame(height: 48)
            .foregroundColor(currentForegroundColor)
            .background(isDisabled || configuration.isPressed ? appearance.colors.background.opacity(0.8) : appearance.colors.background)
            .cornerRadius(appearance.dimensions.cornerRadius)
            .underline(appearance.fonts.title.isUnderlined, color: appearance.fonts.title.underlineColor)
            .strikethrough(appearance.fonts.title.isStrikethrough, color: appearance.fonts.title.strikethroughColor)
            .italic(appearance.fonts.title.isItalic)
            .overlay(
                RoundedRectangle(cornerRadius: appearance.dimensions.cornerRadius)
                    .stroke(currentBorderColor, lineWidth: appearance.dimensions.borderWidth)
            )
    }
}
