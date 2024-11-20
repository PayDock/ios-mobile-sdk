//
//  OutlineButtonStyle.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.10.2024..
//

import SwiftUI

struct OutlineButtonStyle: ButtonStyle {

    var foregroundColor: Color = .primaryColor
    var borderColor: Color = .primaryColor
    var isDisabled: Bool = false

    func makeBody(configuration: Self.Configuration) -> some View {
        let currentForegroundColor = isDisabled || configuration.isPressed ? foregroundColor.opacity(0.3) : foregroundColor
        let currentBorderColor = isDisabled || configuration.isPressed ? borderColor.opacity(0.3) : borderColor
        
        return configuration.label
            .customFont(.body)
            .imageScale(.small)
            .foregroundColor(currentForegroundColor)
            .cornerRadius(.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(currentBorderColor)
            )
            .font(Font.system(size: 19, weight: .semibold))
    }
}
