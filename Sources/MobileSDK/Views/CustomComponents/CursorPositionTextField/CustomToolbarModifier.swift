//
//  CustomToolbarModifier.swift
//  MobileSDK
//
//  Created by Domagoj Grizelj on 22.07.2025..
//  Copyright © 2025 Paydock Ltd.
//

import SwiftUI

struct CustomToolbarModifier: ViewModifier {
    let buttonTitle: String
    let buttonFont: UIFont?
    let buttonTextColor: UIColor?
    let buttonAction: () -> Void

    func body(content: Content) -> some View {
        content
            .environment(\.toolbarButton, ToolbarButtonInfo(
                title: buttonTitle,
                font: buttonFont,
                textColor: buttonTextColor,
                action: buttonAction
            ))
    }
}

extension View {
    func customToolbar(buttonTitle: String, font: UIFont?, textColor: UIColor?, action: @escaping () -> Void) -> some View {
        self.modifier(CustomToolbarModifier(
            buttonTitle: buttonTitle,
            buttonFont: font,
            buttonTextColor: textColor,
            buttonAction: action
        ))
    }
}
