//
//  AnimatableCustomFontModifier.swift
//  MobileSDK
//
//  Copyright © 2024 Paydock Ltd.
//  Created by Domagoj Grizelj on 02.08.2023..
//

import SwiftUI

struct AnimatableCustomFontModifier: AnimatableModifier {

    var animatableData: CGFloat {
        get { size }
        set { size = newValue }
    }

    var size: CGFloat

    func body(content: Content) -> some View {
        content
            .font(Font.custom(Appearance.shared.fontName, fixedSize: size))
    }

}
