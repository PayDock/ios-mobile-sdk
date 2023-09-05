//
//  LargeButtonStyle.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 19.08.2023..
//

import SwiftUI

struct LargeButtonStyle: ButtonStyle {

    let backgroundColor: Color
    let foregroundColor: Color
    let isDisabled: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        let currentForegroundColor = isDisabled || configuration.isPressed ? foregroundColor.opacity(0.3) : foregroundColor
        return configuration.label
            .customFont(.body)
            .frame(height: 48)
            .foregroundColor(currentForegroundColor)
            .background(isDisabled || configuration.isPressed ? backgroundColor.opacity(0.3) : backgroundColor)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(.clear)
            )
            .font(Font.system(size: 19, weight: .semibold))
    }
}
