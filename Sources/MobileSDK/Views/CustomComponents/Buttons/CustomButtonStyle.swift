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

    func makeBody(configuration: Self.Configuration) -> some View {
        let currentForegroundColor = isDisabled || configuration.isPressed ?
            appearance.colors.text.opacity(appearance.colors.disabledOpacity)
            : appearance.colors.text
        let currentBorderColor = isDisabled || configuration.isPressed
            ? appearance.colors.border.opacity(appearance.colors.disabledOpacity)
            : appearance.colors.border

        return configuration.label
            .font(appearance.fonts.title.customFont.scaledFont)
            .imageScale(.small)
            .lineLimit(nil)
            .multilineTextAlignment(.center)
            .foregroundColor(currentForegroundColor)
            .background(isDisabled || configuration.isPressed ?
                        appearance.colors.background.opacity(appearance.colors.disabledOpacity)
                        : appearance.colors.background)
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
