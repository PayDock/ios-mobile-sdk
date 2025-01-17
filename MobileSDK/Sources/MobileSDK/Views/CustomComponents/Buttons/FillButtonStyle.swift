//
//  FillButtonStyle.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 25.10.2024..
//

import SwiftUI

struct FillButtonStyle: ButtonStyle {

    var backgroundColor: Color = .primaryColor
    var foregroundColor: Color = .onPrimaryColor
    var isDisabled: Bool = false

    func makeBody(configuration: Self.Configuration) -> some View {
        let currentForegroundColor = isDisabled || configuration.isPressed ? foregroundColor.opacity(0.3) : foregroundColor
    
        return configuration.label
            .customFont(.body)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .frame(height: 48)
            .imageScale(.small)
            .frame(height: 48)
            .foregroundColor(currentForegroundColor)
            .background(isDisabled || configuration.isPressed ? backgroundColor.opacity(0.8) : backgroundColor)
            .cornerRadius(.buttonCornerRadius)
    }
}
