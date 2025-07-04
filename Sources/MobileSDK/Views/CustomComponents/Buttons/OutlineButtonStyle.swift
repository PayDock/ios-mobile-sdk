//
//  OutlineButtonStyle.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.10.2024..
//

import SwiftUI

struct OutlineButtonStyle: ButtonStyle {

    let appearance: Theme.ButtonAppearance
    var isDisabled: Bool = false
    
    init(appearance: Theme.ButtonAppearance = Theme.ButtonAppearance(),
         isDisabled: Bool = false) {
        self.appearance = appearance
        self.isDisabled = isDisabled
    }

    // TODO: - Consider removing the button stylings to not limit merchant configuration
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
            .cornerRadius(appearance.dimensions.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: appearance.dimensions.cornerRadius)
                    .stroke(currentBorderColor, lineWidth: appearance.dimensions.borderWidth)
            )
    }
}
