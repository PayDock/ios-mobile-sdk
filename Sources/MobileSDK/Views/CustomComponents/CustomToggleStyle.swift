//
//  CustomToggleStyle.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 10.11.2025..
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI

struct CustomToggleStyle: ToggleStyle {

    let appearance: Theme.ToggleAppearance

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Button {
                configuration.isOn.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? appearance.activeColor : (appearance.inactiveColor ?? .clear))
                    .frame(width: 51, height: 31)
                    .overlay(
                        Circle()
                            .fill(appearance.toggleColor ?? .clear)
                            .frame(width: 27, height: 27)
                            .offset(x: configuration.isOn ? 10 : -10)
                            .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(.isButton)
            .accessibilityValue(configuration.isOn ? "On" : "Off")
        }
    }
}

// MARK: - View Extensions

extension View {
    @ViewBuilder
    func conditionalToggleStyle(appearance: Theme.ToggleAppearance) -> some View {
        if appearance.inactiveColor != nil && appearance.inactiveColor != .clear ||
            appearance.toggleColor != nil && appearance.toggleColor != .clear {
            self.toggleStyle(CustomToggleStyle(appearance: appearance))
        } else {
            self.tint(appearance.activeColor)
        }
    }
}
