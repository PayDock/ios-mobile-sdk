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
    var fontName: String

    func body(content: Content) -> some View {
        content
            .font(Font.custom(fontName, size: size))
    }
}
