//
//  FillButtonStyle.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.10.2024..
//

import SwiftUI

struct FillButtonStyle: ButtonStyle {

    let appearance: Theme.ButtonAppearance
    var isDisabled: Bool = false

    // TODO: - Consider removing the button stylings to not limit merchant configuration
    init(appearance: Theme.ButtonAppearance = Theme.ButtonAppearance(),
         isDisabled: Bool = false) {
        self.appearance = appearance
        self.isDisabled = isDisabled
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        let currentForegroundColor = isDisabled || configuration.isPressed ? appearance.colors.text.opacity(0.3) : appearance.colors.text

        return configuration.label
            .font(appearance.fonts.title.customFont.font)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .frame(height: 48)
            .imageScale(.small)
            .foregroundColor(currentForegroundColor)
            .background(isDisabled || configuration.isPressed ? appearance.colors.background.opacity(0.8) : appearance.colors.background)
            .cornerRadius(appearance.dimensions.cornerRadius)
    }
}
